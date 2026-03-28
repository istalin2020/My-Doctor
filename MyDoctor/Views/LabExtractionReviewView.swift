import SwiftUI

/// Shown after GPT-4o Vision parses a lab report image.
/// Displays every extracted value with its unit and optimal range so the
/// user can review, edit, or delete individual entries before applying.
struct LabExtractionReviewView: View {

    // Confirmed editable copy of what the model extracted
    @State private var edited: [String: String]

    // Source truth (read-only, used only for initial state)
    private let original: [String: String]

    // Lookup: field key → LabField metadata (unit, optimal)
    private static let fieldMeta: [String: LabField] = {
        var map: [String: LabField] = [:]
        for panel in ConsultationViewModel.labPanels {
            for field in panel.fields { map[field.key] = field }
        }
        return map
    }()

    private let onApply: ([String: String]) -> Void

    @Environment(\.dismiss) private var dismiss

    // Keys grouped by their panel (preserves panel ordering)
    private var groupedKeys: [(panelName: String, panelIcon: String, keys: [String])] {
        var groups: [(panelName: String, panelIcon: String, keys: [String])] = []
        for panel in ConsultationViewModel.labPanels {
            let matching = panel.fields
                .map(\.key)
                .filter { edited[$0] != nil }
            if !matching.isEmpty {
                groups.append((panel.name, panel.icon, matching))
            }
        }
        // Anything the model returned that isn't in a known panel
        let known = Set(ConsultationViewModel.labPanels.flatMap { $0.fields.map(\.key) })
        let extra  = edited.keys.filter { !known.contains($0) }.sorted()
        if !extra.isEmpty {
            groups.append(("Other", "🔬", extra))
        }
        return groups
    }

    init(extracted: [String: String], onApply: @escaping ([String: String]) -> Void) {
        self.original  = extracted
        self._edited   = State(initialValue: extracted)
        self.onApply   = onApply
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()

                if edited.isEmpty {
                    emptyState
                } else {
                    reviewList
                }
            }
            .navigationTitle("Review Extracted Values")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.init(white: 0.5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply \(edited.count) Values") {
                        onApply(edited.filter { !$0.value.isEmpty })
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.gold)
                    .disabled(edited.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.init(white: 0.3))
            Text("No values found")
                .font(.headline)
                .foregroundColor(.init(white: 0.5))
            Text("Try a clearer, well-lit photo or a higher-resolution PDF scan.")
                .font(.subheadline)
                .foregroundColor(.init(white: 0.35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Dismiss") { dismiss() }
                .foregroundColor(.gold)
        }
    }

    // MARK: - Review list

    private var reviewList: some View {
        ScrollView {
            VStack(spacing: 16) {
                summaryBanner
                ForEach(groupedKeys, id: \.panelName) { group in
                    panelSection(group)
                }
                disclaimer
            }
            .padding(16)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Summary banner

    private var summaryBanner: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gold.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.gold)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("\(edited.count) biomarker\(edited.count == 1 ? "" : "s") extracted")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text("Review each value, edit if needed, then tap Apply.")
                    .font(.caption)
                    .foregroundColor(.init(white: 0.45))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gold.opacity(0.3), lineWidth: 1))
        .cornerRadius(14)
    }

    // MARK: - Panel section

    private func panelSection(
        _ group: (panelName: String, panelIcon: String, keys: [String])
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section header
            HStack(spacing: 6) {
                Text(group.panelIcon)
                Text(group.panelName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.gold)
                Spacer()
                Text("\(group.keys.count) value\(group.keys.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.gold.opacity(0.7))
            }

            VStack(spacing: 1) {
                ForEach(group.keys, id: \.self) { key in
                    fieldRow(key: key)
                    if key != group.keys.last {
                        Divider().overlay(Color.white.opacity(0.06))
                    }
                }
            }
            .background(Color.navyCard)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
            .cornerRadius(12)
        }
    }

    // MARK: - Field row

    private func fieldRow(key: String) -> some View {
        let meta = Self.fieldMeta[key]

        return HStack(spacing: 10) {
            // Name + optimal hint
            VStack(alignment: .leading, spacing: 2) {
                Text(key)
                    .font(.subheadline)
                    .foregroundColor(.white)
                if let meta {
                    Text("Optimal: \(meta.optimal)")
                        .font(.caption2)
                        .foregroundColor(.init(white: 0.35))
                }
            }

            Spacer()

            // Editable value
            TextField("—", text: Binding(
                get: { edited[key] ?? "" },
                set: { edited[key] = $0.isEmpty ? nil : $0 }
            ))
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundColor(.gold)
            .frame(width: 72)

            // Unit
            if let meta {
                Text(meta.unit)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.35))
                    .frame(width: 48, alignment: .leading)
            }

            // Delete button
            Button {
                edited.removeValue(forKey: key)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.init(white: 0.25))
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("⚠️ Always verify AI-extracted values against your original report before proceeding.")
            .font(.caption2)
            .foregroundColor(.init(white: 0.3))
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }
}

#Preview {
    LabExtractionReviewView(
        extracted: [
            "HbA1c": "5.8",
            "Fasting Glucose": "102",
            "LDL-C": "138",
            "HDL-C": "44",
            "Triglycerides": "165",
            "Vitamin D (25-OH)": "21",
            "TSH": "3.1",
            "hsCRP": "2.4",
        ]
    ) { _ in }
}
