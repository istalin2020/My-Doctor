import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @State private var showPatient  = false
    @State private var showLabs     = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        heroHeader
                        ModeSelectorView()
                        dataCards
                        analyzeButton
                        disclaimer
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gold)
                    }
                }
            }
            .sheet(isPresented: $showPatient)  { PatientIntakeView() }
            .sheet(isPresented: $showLabs)     { LabsInputView() }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(isPresented: $vm.showReport) {
                AnalysisView()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Subviews

    private var heroHeader: some View {
        VStack(spacing: 8) {
            // Badge
            HStack(spacing: 6) {
                Circle().fill(Color.gold).frame(width: 6, height: 6)
                Text("Elite Concierge Medicine AI")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.gold.opacity(0.12))
            .overlay(Capsule().stroke(Color.gold.opacity(0.3), lineWidth: 1))
            .clipShape(Capsule())

            Text("Your Sovereign\nPhysician")
                .font(.system(size: 34, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.gold, .goldLight, .gold],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Submit your labs and medical history.\nReceive an elite 360° health blueprint.")
                .font(.subheadline)
                .foregroundColor(.init(white: 0.55))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private var dataCards: some View {
        VStack(spacing: 12) {
            // Patient profile card
            cardButton(
                title: "Patient Profile",
                subtitle: vm.patientData.name.isEmpty ? "Age, gender, medical history, lifestyle" : "\(vm.patientData.name), \(vm.patientData.age) yrs — \(vm.patientData.gender)",
                icon: "person.fill",
                isFilled: !vm.patientData.age.isEmpty
            ) { showPatient = true }

            // Lab values card
            cardButton(
                title: "Lab Report",
                subtitle: vm.filledLabCount == 0 ? "Enter your most recent biomarker values" : "\(vm.filledLabCount) biomarker\(vm.filledLabCount == 1 ? "" : "s") entered",
                icon: "cross.vial.fill",
                isFilled: vm.filledLabCount > 0
            ) { showLabs = true }
        }
    }

    private func cardButton(
        title: String,
        subtitle: String,
        icon: String,
        isFilled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isFilled ? Color.gold.opacity(0.15) : Color.navyCard)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(isFilled ? .gold : .init(white: 0.45))
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: isFilled ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundColor(isFilled ? .gold : .init(white: 0.3))
                    .font(.system(size: isFilled ? 18 : 14))
            }
            .padding(14)
            .background(Color.navyCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFilled ? Color.gold.opacity(0.4) : Color.white.opacity(0.07), lineWidth: 1)
            )
            .cornerRadius(14)
        }
    }

    private var analyzeButton: some View {
        VStack(spacing: 10) {
            Button {
                Task { await vm.analyze() }
            } label: {
                HStack(spacing: 8) {
                    if vm.isStreaming {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.navyDark)
                            .scaleEffect(0.8)
                    }
                    Text(vm.isStreaming ? "Analyzing…" : "Generate Elite Health Blueprint")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    vm.hasMinimalData
                        ? LinearGradient(colors: [Color(red: 0.66, green: 0.51, blue: 0.11), .gold, .goldLight],
                                         startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                                         startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(14)
                .foregroundColor(vm.hasMinimalData ? Color.navyDark : .init(white: 0.4))
            }
            .disabled(!vm.hasMinimalData || vm.isStreaming)

            if !vm.hasMinimalData {
                Text("Enter age & gender, or at least one lab value to proceed")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.35))
            }
        }
        .padding(.top, 4)
    }

    private var disclaimer: some View {
        Text("⚠️ This AI analysis is for optimization guidance only. It does not replace emergency in-person medical care.")
            .font(.caption2)
            .foregroundColor(.init(white: 0.3))
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConsultationViewModel())
}
