import SwiftUI

struct LabsInputView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        tipBanner
                        ForEach(ConsultationViewModel.labPanels) { panel in
                            panelCard(panel)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Lab Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.gold)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        vm.labValues = [:]
                    }
                    .foregroundColor(.init(white: 0.4))
                    .font(.subheadline)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Tip Banner

    private var tipBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡")
            Text("Enter values from your most recent report. Blank fields are ignored. The Sovereign Physician evaluates against **optimal** ranges, not just \"normal\" ranges.")
                .font(.caption)
                .foregroundColor(.init(white: 0.5))
        }
        .padding(12)
        .background(Color.gold.opacity(0.06))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gold.opacity(0.2), lineWidth: 1))
        .cornerRadius(10)
    }

    // MARK: - Panel Card

    private func panelCard(_ panel: LabPanel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(panel.icon).font(.title3)
                Text(panel.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.gold)
                Spacer()
                let filled = panel.fields.filter { !(vm.labValues[$0.key] ?? "").isEmpty }.count
                if filled > 0 {
                    Text("\(filled)/\(panel.fields.count)")
                        .font(.caption2)
                        .foregroundColor(.gold)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.gold.opacity(0.12))
                        .cornerRadius(6)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(panel.fields) { field in
                    fieldCell(field)
                }
            }
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.07), lineWidth: 1))
        .cornerRadius(14)
    }

    // MARK: - Field Cell

    private func fieldCell(_ field: LabField) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(field.key)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(field.unit)
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.3))
            }

            TextField(field.placeholder, text: Binding(
                get: { vm.labValues[field.key] ?? "" },
                set: { vm.labValues[field.key] = $0 }
            ))
            .keyboardType(.decimalPad)
            .font(.subheadline.monospacedDigit())
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.navyDark)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        (vm.labValues[field.key] ?? "").isEmpty
                            ? Color.white.opacity(0.1)
                            : Color.gold.opacity(0.4),
                        lineWidth: 1
                    )
            )
            .cornerRadius(8)

            Text("Optimal: \(field.optimal)")
                .font(.caption2)
                .foregroundColor(.init(white: 0.3))
        }
    }
}

#Preview {
    LabsInputView()
        .environmentObject(ConsultationViewModel())
}
