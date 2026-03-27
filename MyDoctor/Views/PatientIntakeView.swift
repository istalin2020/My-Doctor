import SwiftUI

private let genders     = ["Male", "Female", "Other"]
private let regions     = [
    "Indian — Vegetarian", "Indian — Non-Vegetarian", "Indian — Vegan",
    "US — Standard American Diet", "US — Health-Conscious",
    "Mediterranean", "Other / Mixed",
]
private let smokingOpts = ["Never", "Former (quit)", "Occasional", "Daily smoker"]
private let alcoholOpts = ["None", "Occasional (social)", "Moderate (1–2/day)", "Heavy (3+/day)"]
private let activityOpts = [
    "Sedentary (desk job, no exercise)",
    "Light (1–2 days/week)",
    "Moderate (3–4 days/week)",
    "Active (5+ days/week)",
    "Athlete / Daily training",
]
private let allConditions = [
    "Hypertension", "Type 2 Diabetes", "Pre-Diabetes", "High Cholesterol",
    "Hypothyroidism", "Hyperthyroidism", "Heart Disease", "Fatty Liver (NAFLD)",
    "PCOS", "Sleep Apnea", "Obesity", "Anxiety / Depression",
    "Osteoporosis", "Arthritis", "Chronic Kidney Disease", "Autoimmune Condition",
]

struct PatientIntakeView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()
                Form {
                    profileSection
                    complaintsSection
                    conditionsSection
                    medicationsSection
                    lifestyleSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Patient Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.gold)
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Sections

    private var profileSection: some View {
        Section {
            HStack {
                formLabel("Full Name")
                TextField("e.g. Rahul Sharma", text: $vm.patientData.name)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                formLabel("Age")
                TextField("45", text: $vm.patientData.age)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            Picker("Gender", selection: $vm.patientData.gender) {
                Text("Select").tag("")
                ForEach(genders, id: \.self) { Text($0).tag($0) }
            }
            Picker("Dietary Background", selection: $vm.patientData.region) {
                Text("Select region").tag("")
                ForEach(regions, id: \.self) { Text($0).tag($0) }
            }
            HStack {
                formLabel("Height (cm)")
                TextField("175", text: $vm.patientData.height)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                formLabel("Weight (kg)")
                TextField("82", text: $vm.patientData.weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            if !vm.patientData.bmi.isEmpty && vm.patientData.bmi != "N/A" {
                HStack {
                    formLabel("BMI")
                    Spacer()
                    Text(vm.patientData.bmi)
                        .foregroundColor(.gold)
                        .fontWeight(.semibold)
                }
            }
        } header: { sectionHeader("👤 Patient Profile") }
    }

    private var complaintsSection: some View {
        Section {
            TextEditor(text: $vm.patientData.chiefComplaints)
                .frame(minHeight: 80)
                .foregroundColor(.white)
        } header: { sectionHeader("🎯 Chief Complaints & Goals") }
        footer: {
            Text("Describe your symptoms, energy issues, and performance goals")
                .font(.caption)
                .foregroundColor(.init(white: 0.4))
        }
    }

    private var conditionsSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(allConditions, id: \.self) { condition in
                    let selected = vm.patientData.conditions.contains(condition)
                    Button {
                        if selected {
                            vm.patientData.conditions.removeAll { $0 == condition }
                        } else {
                            vm.patientData.conditions.append(condition)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected ? .gold : .init(white: 0.35))
                                .font(.system(size: 13))
                            Text(condition)
                                .font(.caption)
                                .foregroundColor(selected ? .gold : .init(white: 0.55))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(selected ? Color.gold.opacity(0.1) : Color.navyCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selected ? Color.gold.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 4)
        } header: { sectionHeader("🏥 Active Conditions") }
    }

    private var medicationsSection: some View {
        Section {
            TextEditor(text: $vm.patientData.medications)
                .frame(minHeight: 70)
                .foregroundColor(.white)
            TextEditor(text: $vm.patientData.familyHistory)
                .frame(minHeight: 70)
                .foregroundColor(.white)
            HStack {
                formLabel("Allergies")
                TextField("e.g. Penicillin, lactose", text: $vm.patientData.allergies)
                    .multilineTextAlignment(.trailing)
            }
        } header: { sectionHeader("💊 Medications & History") }
        footer: {
            Text("List medications with dose, and relevant family conditions")
                .font(.caption)
                .foregroundColor(.init(white: 0.4))
        }
    }

    private var lifestyleSection: some View {
        Section {
            Picker("Smoking", selection: $vm.patientData.smoking) {
                Text("Select").tag("")
                ForEach(smokingOpts, id: \.self) { Text($0).tag($0) }
            }
            Picker("Alcohol", selection: $vm.patientData.alcohol) {
                Text("Select").tag("")
                ForEach(alcoholOpts, id: \.self) { Text($0).tag($0) }
            }
            HStack {
                formLabel("Sleep (hrs/night)")
                TextField("7.0", text: $vm.patientData.sleepHours)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            Picker("Activity Level", selection: $vm.patientData.activityLevel) {
                Text("Select").tag("")
                ForEach(activityOpts, id: \.self) { Text($0).tag($0) }
            }
        } header: { sectionHeader("🌿 Lifestyle") }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundColor(.gold)
            .textCase(nil)
    }

    private func formLabel(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.init(white: 0.7))
    }
}

#Preview {
    PatientIntakeView()
        .environmentObject(ConsultationViewModel())
}
