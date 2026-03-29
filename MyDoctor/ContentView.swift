import SwiftUI

// MARK: - Home Screen (Tile Layout)

struct ContentView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @State private var showPatient    = false
    @State private var showLabs       = false
    @State private var showSettings   = false
    @State private var showTodayInput = false
    @State private var showModeSheet  = false

    // Tile height
    private let tileHeight: CGFloat = 172

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerBar
                        tileGrid
                        if !vm.report.isEmpty { viewBlueprintButton }
                        generateButton
                        disclaimer
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 44)
                }
            }
            .navigationBarHidden(true)
            // Sheets
            .sheet(isPresented: $showPatient)    { PatientIntakeView() }
            .sheet(isPresented: $showLabs)       { LabsInputView() }
            .sheet(isPresented: $showSettings)   { SettingsView() }
            .sheet(isPresented: $showTodayInput) { TodayInputView() }
            .sheet(isPresented: $showModeSheet)  { ConsultationModeSheet() }
            .navigationDestination(isPresented: $vm.showReport) { AnalysisView() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.07, green: 0.07, blue: 0.16),
                Color(red: 0.04, green: 0.04, blue: 0.10),
                Color(red: 0.02, green: 0.02, blue: 0.06),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Doctor")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.gold, .goldLight],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                Text("Elite Concierge Medicine AI")
                    .font(.caption)
                    .foregroundColor(.init(white: 0.45))
            }
            Spacer()
            Button { showSettings = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 38, height: 38)
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gold)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - 2×2 Tile Grid

    private var tileGrid: some View {
        VStack(spacing: 14) {
            // Row 1: Patient Profile | Lab Report
            HStack(spacing: 14) {
                HomeTile(
                    gradient: [
                        Color(red: 0.38, green: 0.18, blue: 0.82),
                        Color(red: 0.55, green: 0.25, blue: 0.98),
                    ],
                    shadowColor: Color(red: 0.45, green: 0.2, blue: 0.9),
                    icon: "person.fill",
                    title: "Patient Profile",
                    subtitle: vm.patientData.name.isEmpty
                        ? "Tap to add your health profile"
                        : vm.patientData.name,
                    detail: vm.patientData.age.isEmpty ? nil
                        : "\(vm.patientData.age) yrs · \(vm.patientData.gender)",
                    badgeText: vm.patientData.age.isEmpty ? nil : "Active",
                    isComplete: !vm.patientData.age.isEmpty,
                    height: tileHeight
                ) { showPatient = true }

                HomeTile(
                    gradient: [
                        Color(red: 0.0,  green: 0.42, blue: 0.88),
                        Color(red: 0.0,  green: 0.65, blue: 1.0),
                    ],
                    shadowColor: Color(red: 0.0, green: 0.5, blue: 0.9),
                    icon: "cross.vial.fill",
                    title: "Lab Report",
                    subtitle: vm.filledLabCount == 0
                        ? "Upload or enter biomarkers"
                        : "\(vm.filledLabCount) biomarkers",
                    detail: vm.filledLabCount == 0 ? nil : "Tap to review values",
                    badgeText: vm.filledLabCount > 0 ? "\(vm.filledLabCount)" : nil,
                    isComplete: vm.filledLabCount > 0,
                    height: tileHeight
                ) { showLabs = true }
            }

            // Row 2: Consultation Method | Today's Input
            HStack(spacing: 14) {
                HomeTile(
                    gradient: [
                        Color(red: 0.70, green: 0.45, blue: 0.05),
                        Color(red: 0.90, green: 0.65, blue: 0.10),
                    ],
                    shadowColor: Color.gold,
                    icon: "waveform.path.ecg",
                    title: "Consultation",
                    subtitle: vm.mode.title,
                    detail: "Tap to change mode",
                    badgeText: vm.mode.emoji,
                    isComplete: true,
                    height: tileHeight
                ) { showModeSheet = true }

                HomeTile(
                    gradient: [
                        Color(red: 0.04, green: 0.55, blue: 0.38),
                        Color(red: 0.10, green: 0.78, blue: 0.55),
                    ],
                    shadowColor: Color(red: 0.1, green: 0.7, blue: 0.5),
                    icon: "fork.knife.circle.fill",
                    title: "Today's Input",
                    subtitle: vm.todayInput.hasAnyData
                        ? "\(vm.todayInput.totalCalories) kcal"
                        : "Log meals & activity",
                    detail: vm.todayInput.hasAnyData
                        ? "\(vm.todayInput.waterGlasses) glasses · \(vm.todayInput.workoutMinutes) min"
                        : "Tap to track your day",
                    badgeText: vm.todayInput.hasAnyData ? "✓" : nil,
                    isComplete: vm.todayInput.hasAnyData,
                    height: tileHeight
                ) { showTodayInput = true }
            }
        }
    }

    // MARK: - View Blueprint Button

    private var viewBlueprintButton: some View {
        Button { vm.showReport = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.gold)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Health Blueprint")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text("View report · Re-consultation · Meal & fitness plan")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gold.opacity(0.6))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gold.opacity(0.35), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        VStack(spacing: 10) {
            Button {
                Task { await vm.analyze() }
            } label: {
                HStack(spacing: 10) {
                    if vm.isStreaming {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.black.opacity(0.7))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: vm.report.isEmpty ? "sparkles" : "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(vm.isStreaming ? "Analyzing…"
                         : vm.report.isEmpty ? "Generate Elite Health Blueprint"
                         : "Re-generate Blueprint")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    Group {
                        if vm.hasMinimalData {
                            LinearGradient(
                                colors: [Color(red: 0.62, green: 0.46, blue: 0.08), .gold, .goldLight],
                                startPoint: .leading, endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [Color.white.opacity(0.07), Color.white.opacity(0.07)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(16)
                .foregroundColor(vm.hasMinimalData ? .black.opacity(0.8) : .init(white: 0.35))
                .shadow(
                    color: vm.hasMinimalData ? Color.gold.opacity(0.4) : .clear,
                    radius: 10, x: 0, y: 4
                )
            }
            .disabled(!vm.hasMinimalData || vm.isStreaming)

            if !vm.hasMinimalData {
                Text("Add patient profile or lab values to proceed")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.3))
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("⚠️ For health optimization guidance only. Not a substitute for professional medical care.")
            .font(.caption2)
            .foregroundColor(.init(white: 0.28))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Reusable Home Tile

struct HomeTile: View {
    let gradient:    [Color]
    let shadowColor: Color
    let icon:        String
    let title:       String
    let subtitle:    String
    var detail:      String? = nil
    var badgeText:   String? = nil
    var isComplete:  Bool    = false
    var height:      CGFloat = 172
    let action:      () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Background gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Sheen overlay (top-left light)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )

                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Top row: icon + badge
                    HStack(alignment: .top) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 42, height: 42)
                            Image(systemName: icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        if let badge = badgeText {
                            Text(badge)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(gradient.last ?? .white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.92))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 14)

                    Spacer()

                    // Bottom text
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.75))
                            .textCase(.uppercase)
                            .tracking(0.5)

                        Text(subtitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        if let detail {
                            Text(detail)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.65))
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .cornerRadius(20)
            .shadow(color: shadowColor.opacity(0.38), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Consultation Mode Sheet

struct ConsultationModeSheet: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.06, green: 0.06, blue: 0.13).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        Text("Choose how the AI approaches your consultation.")
                            .font(.subheadline)
                            .foregroundColor(.init(white: 0.5))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.horizontal, 24)

                        ForEach(ConsultationMode.allCases) { mode in
                            modeCard(mode)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Consultation Mode")
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func modeCard(_ mode: ConsultationMode) -> some View {
        let selected = vm.mode == mode

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.mode = mode
            }
        } label: {
            HStack(spacing: 16) {
                // Mode emoji in rounded square
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(mode.accentColor.opacity(selected ? 0.25 : 0.12))
                        .frame(width: 54, height: 54)
                    Text(mode.emoji)
                        .font(.system(size: 28))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.init(white: 0.5))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Selection ring
                ZStack {
                    Circle()
                        .stroke(
                            selected ? mode.accentColor : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    if selected {
                        Circle()
                            .fill(mode.accentColor)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(selected
                          ? mode.accentColor.opacity(0.12)
                          : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                selected ? mode.accentColor.opacity(0.6) : Color.white.opacity(0.07),
                                lineWidth: selected ? 1.5 : 1
                            )
                    )
            )
            .shadow(
                color: selected ? mode.accentColor.opacity(0.25) : .clear,
                radius: 8, x: 0, y: 3
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConsultationViewModel())
}
