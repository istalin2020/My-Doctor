import Foundation
import SwiftUI

// MARK: - Theme Colors

extension Color {
    static let gold      = Color(red: 0.788, green: 0.635, blue: 0.153)
    static let goldLight = Color(red: 0.902, green: 0.784, blue: 0.290)
    static let navyDark  = Color(red: 0.024, green: 0.039, blue: 0.078)
    static let navyMid   = Color(red: 0.039, green: 0.059, blue: 0.118)
    static let navyCard  = Color(red: 0.051, green: 0.082, blue: 0.149)
}

// MARK: - Consultation Mode

enum ConsultationMode: String, CaseIterable, Identifiable, Codable {
    case standard  = "standard"
    case longevity = "longevity"
    case toughlove = "toughlove"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard:  return "Sovereign Physician"
        case .longevity: return "Longevity Scientist"
        case .toughlove: return "Tough Love Coach"
        }
    }

    var emoji: String {
        switch self {
        case .standard:  return "⚕️"
        case .longevity: return "🧬"
        case .toughlove: return "🔥"
        }
    }

    var description: String {
        switch self {
        case .standard:
            return "360° optimization. Optimal biomarker ranges, regional nutrition, performance protocols."
        case .longevity:
            return "Cellular deep-dive. mTOR/AMPK, NAD+, telomere science, and bio-hacking protocols."
        case .toughlove:
            return "Zero tolerance. Brutally honest. Immediate lifestyle overhaul. No excuses."
        }
    }

    var accentColor: Color {
        switch self {
        case .standard:  return .gold
        case .longevity: return Color(red: 0.388, green: 0.4, blue: 0.9)
        case .toughlove: return Color(red: 0.9, green: 0.25, blue: 0.2)
        }
    }
}

// MARK: - Patient Data
// Codable so it can be persisted to UserDefaults across restarts and builds.

struct PatientData: Codable {
    var name:            String = ""
    var age:             String = ""
    var gender:          String = ""
    var region:          String = ""
    var height:          String = ""
    var weight:          String = ""
    var chiefComplaints: String = ""
    var conditions:      [String] = []
    var medications:     String = ""
    var allergies:       String = ""
    var familyHistory:   String = ""
    var smoking:         String = ""
    var alcohol:         String = ""
    var sleepHours:      String = ""
    var activityLevel:   String = ""

    // Computed — not stored, so excluded from Codable automatically.
    var bmi: String {
        guard let h = Double(height), let w = Double(weight), h > 0 else { return "N/A" }
        return String(format: "%.1f", w / ((h / 100) * (h / 100)))
    }
}

// MARK: - Lab Input Models

struct LabPanel: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let fields: [LabField]
}

struct LabField: Identifiable {
    let id = UUID()
    let key: String
    let unit: String
    let placeholder: String
    let optimal: String
}

// MARK: - Persistence Keys

private enum PersistenceKey {
    static let patientData = "sp_patient_data_v1"
    static let labValues   = "sp_lab_values_v1"
    static let mode        = "sp_mode_v1"
}

// MARK: - View Model

@MainActor
final class ConsultationViewModel: ObservableObject {

    // ── Persisted state ───────────────────────────────────────────────────────
    // didSet hooks call scheduleSave() so any mutation — whether from a text
    // field, a picker, a bulk lab-import, or a reset — is automatically
    // written to UserDefaults within 0.4 s of the last change.

    @Published var patientData: PatientData = PatientData() {
        didSet { scheduleSave() }
    }

    @Published var labValues: [String: String] = [:] {
        didSet { scheduleSave() }
    }

    @Published var mode: ConsultationMode = .standard {
        didSet { scheduleSave() }
    }

    // ── Transient state (not persisted) ──────────────────────────────────────
    @Published var report:      String = ""
    @Published var isStreaming: Bool   = false
    @Published var error:       String?
    @Published var showReport:  Bool   = false

    // ── Init ─────────────────────────────────────────────────────────────────

    init() {
        loadAll()
    }

    // MARK: - Derived

    var hasMinimalData: Bool {
        (!patientData.age.isEmpty && !patientData.gender.isEmpty) ||
        labValues.values.contains(where: { !$0.isEmpty })
    }

    var filledLabCount: Int {
        labValues.values.filter { !$0.isEmpty }.count
    }

    // MARK: - Analysis

    func analyze() async {
        guard !isStreaming else { return }
        error      = nil
        report     = ""
        showReport = true
        isStreaming = true

        let system = PromptEngine.systemPrompt(mode: mode)
        let user   = PromptEngine.userMessage(patientData: patientData, labValues: labValues)

        do {
            for try await token in OpenAIService.stream(system: system, user: user) {
                report += token
            }
        } catch {
            self.error = error.localizedDescription
            showReport = false
        }

        isStreaming = false
    }

    func reset() {
        report      = ""
        error       = nil
        isStreaming  = false
        showReport   = false
        // Note: patientData, labValues, and mode are intentionally NOT cleared
        // here — the user's entered data must survive a reset.
    }

    // MARK: - Persistence

    // Debounce timer: we commit at most once per 0.4 s so rapid keystrokes
    // (e.g. typing in a lab field) don't flood UserDefaults.
    private var saveTask: DispatchWorkItem?
    // Guard that prevents a pointless save() call during the initial loadAll().
    private var isLoadingData = false

    private func scheduleSave() {
        guard !isLoadingData else { return }
        saveTask?.cancel()
        let task = DispatchWorkItem { [weak self] in self?.commitSave() }
        saveTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: task)
    }

    /// Force an immediate save — called when the app moves to the background
    /// so in-flight debounced saves are not lost.
    func saveImmediately() {
        saveTask?.cancel()
        commitSave()
    }

    private func commitSave() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(patientData) {
            UserDefaults.standard.set(data, forKey: PersistenceKey.patientData)
        }
        if let data = try? encoder.encode(labValues) {
            UserDefaults.standard.set(data, forKey: PersistenceKey.labValues)
        }
        UserDefaults.standard.set(mode.rawValue, forKey: PersistenceKey.mode)
    }

    private func loadAll() {
        isLoadingData = true
        defer { isLoadingData = false }

        let decoder = JSONDecoder()

        if let raw  = UserDefaults.standard.data(forKey: PersistenceKey.patientData),
           let decoded = try? decoder.decode(PatientData.self, from: raw) {
            patientData = decoded
        }

        if let raw  = UserDefaults.standard.data(forKey: PersistenceKey.labValues),
           let decoded = try? decoder.decode([String: String].self, from: raw) {
            labValues = decoded
        }

        if let raw     = UserDefaults.standard.string(forKey: PersistenceKey.mode),
           let decoded = ConsultationMode(rawValue: raw) {
            mode = decoded
        }
    }

    // MARK: - Lab Panels (static reference data)

    static let labPanels: [LabPanel] = [
        LabPanel(name: "Glycemic Control", icon: "🩸", fields: [
            LabField(key: "Fasting Glucose",    unit: "mg/dL",   placeholder: "95",   optimal: "70–85 mg/dL"),
            LabField(key: "HbA1c",              unit: "%",        placeholder: "5.8",  optimal: "< 5.4%"),
            LabField(key: "Fasting Insulin",    unit: "μIU/mL",  placeholder: "8",    optimal: "< 5 μIU/mL"),
            LabField(key: "HOMA-IR",            unit: "index",   placeholder: "1.9",  optimal: "< 1.0"),
        ]),
        LabPanel(name: "Lipid Panel", icon: "🫀", fields: [
            LabField(key: "Total Cholesterol",  unit: "mg/dL",   placeholder: "210",  optimal: "< 180 mg/dL"),
            LabField(key: "LDL-C",              unit: "mg/dL",   placeholder: "140",  optimal: "< 70 mg/dL"),
            LabField(key: "HDL-C",              unit: "mg/dL",   placeholder: "45",   optimal: "> 60 mg/dL"),
            LabField(key: "Triglycerides",      unit: "mg/dL",   placeholder: "160",  optimal: "< 80 mg/dL"),
            LabField(key: "Lp(a)",              unit: "mg/dL",   placeholder: "35",   optimal: "< 30 mg/dL"),
            LabField(key: "ApoB",               unit: "mg/dL",   placeholder: "100",  optimal: "< 80 mg/dL"),
        ]),
        LabPanel(name: "Complete Blood Count", icon: "🔬", fields: [
            LabField(key: "Hemoglobin",         unit: "g/dL",    placeholder: "13.5", optimal: "14–17 (M)"),
            LabField(key: "WBC",                unit: "×10³/μL", placeholder: "7.2",  optimal: "4.5–7.5"),
            LabField(key: "Platelets",          unit: "×10³/μL", placeholder: "220",  optimal: "150–350"),
            LabField(key: "MCV",                unit: "fL",      placeholder: "86",   optimal: "85–95 fL"),
        ]),
        LabPanel(name: "Metabolic Panel", icon: "🏥", fields: [
            LabField(key: "ALT (SGPT)",         unit: "U/L",     placeholder: "35",   optimal: "< 25 U/L"),
            LabField(key: "AST (SGOT)",         unit: "U/L",     placeholder: "28",   optimal: "< 25 U/L"),
            LabField(key: "GGT",                unit: "U/L",     placeholder: "40",   optimal: "< 25 U/L"),
            LabField(key: "Creatinine",         unit: "mg/dL",   placeholder: "1.0",  optimal: "0.8–1.1"),
            LabField(key: "eGFR",               unit: "mL/min",  placeholder: "85",   optimal: "> 90"),
            LabField(key: "Uric Acid",          unit: "mg/dL",   placeholder: "6.5",  optimal: "< 5.5"),
        ]),
        LabPanel(name: "Thyroid", icon: "🦋", fields: [
            LabField(key: "TSH",                unit: "mIU/L",   placeholder: "2.8",  optimal: "1.0–2.0"),
            LabField(key: "Free T3",            unit: "pg/mL",   placeholder: "2.9",  optimal: "3.2–4.2"),
            LabField(key: "Free T4",            unit: "ng/dL",   placeholder: "1.1",  optimal: "1.0–1.5"),
        ]),
        LabPanel(name: "Hormones", icon: "⚡", fields: [
            LabField(key: "Total Testosterone", unit: "ng/dL",   placeholder: "480",  optimal: "700–1000 (M)"),
            LabField(key: "DHEA-S",             unit: "μg/dL",   placeholder: "180",  optimal: "200–350"),
            LabField(key: "Cortisol (AM)",      unit: "μg/dL",   placeholder: "18",   optimal: "10–20"),
            LabField(key: "IGF-1",              unit: "ng/mL",   placeholder: "160",  optimal: "150–250"),
        ]),
        LabPanel(name: "Vitamins & Minerals", icon: "💊", fields: [
            LabField(key: "Vitamin D (25-OH)",  unit: "ng/mL",   placeholder: "22",   optimal: "60–80"),
            LabField(key: "Vitamin B12",        unit: "pg/mL",   placeholder: "380",  optimal: "600–900"),
            LabField(key: "Ferritin",           unit: "ng/mL",   placeholder: "25",   optimal: "70–150 (M)"),
            LabField(key: "Magnesium (RBC)",    unit: "mg/dL",   placeholder: "4.2",  optimal: "5.2–6.5"),
            LabField(key: "Zinc",               unit: "μg/dL",   placeholder: "70",   optimal: "80–120"),
        ]),
        LabPanel(name: "Inflammation", icon: "🧬", fields: [
            LabField(key: "hsCRP",              unit: "mg/L",    placeholder: "2.1",  optimal: "< 0.5"),
            LabField(key: "Homocysteine",       unit: "μmol/L",  placeholder: "14",   optimal: "< 7"),
            LabField(key: "ESR",                unit: "mm/hr",   placeholder: "18",   optimal: "< 10"),
        ]),
    ]
}
