import SwiftUI

// MARK: - Home Screen

struct ContentView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @State private var showPatient    = false
    @State private var showLabs       = false
    @State private var showSettings   = false
    @State private var showTodayInput = false
    @State private var showModeSheet  = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Deep slate background
                Color(red: 0.10, green: 0.10, blue: 0.14).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerBar
                        tileGrid
                        if !vm.report.isEmpty { viewBlueprintButton }
                        generateButton
                        disclaimer
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPatient)    { PatientIntakeView() }
            .sheet(isPresented: $showLabs)       { LabsInputView() }
            .sheet(isPresented: $showSettings)   { SettingsView() }
            .sheet(isPresented: $showTodayInput) { TodayInputView() }
            .sheet(isPresented: $showModeSheet)  { ConsultationModeSheet() }
            .navigationDestination(isPresented: $vm.showReport) { AnalysisView() }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("My Doctor")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.gold, .goldLight],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                Text("Your AI Health Companion")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.init(white: 0.45))
            }
            Spacer()
            Button { showSettings = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 42, height: 42)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.gold)
                }
            }
        }
        .padding(.top, 10)
    }

    // MARK: - 2 × 2 Tile Grid

    private var tileGrid: some View {
        GeometryReader { geo in
            let gap: CGFloat   = 14
            let side: CGFloat  = (geo.size.width - gap) / 2

            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    // Tile 1 — Patient Profile (purple)
                    AppTile(
                        color1: Color(red: 0.50, green: 0.28, blue: 0.94),
                        color2: Color(red: 0.65, green: 0.43, blue: 1.00),
                        icon:   "person.circle",
                        title:  "Patient Profile",
                        line1:  vm.patientData.name.isEmpty
                                    ? "Add your details" : vm.patientData.name,
                        line2:  vm.patientData.age.isEmpty
                                    ? "Age · Gender · History"
                                    : "\(vm.patientData.age) yrs · \(vm.patientData.gender)",
                        showDot: !vm.patientData.age.isEmpty,
                        size:   side
                    ) { showPatient = true }

                    // Tile 2 — Lab Report (coral)
                    AppTile(
                        color1: Color(red: 0.94, green: 0.34, blue: 0.40),
                        color2: Color(red: 1.00, green: 0.55, blue: 0.55),
                        icon:   "cross.vial",
                        title:  "Lab Report",
                        line1:  vm.filledLabCount == 0
                                    ? "Upload your labs"
                                    : "\(vm.filledLabCount) Biomarkers",
                        line2:  vm.filledLabCount == 0
                                    ? "Auto-extract from report"
                                    : "Tap to review values",
                        showDot: vm.filledLabCount > 0,
                        size:   side
                    ) { showLabs = true }
                }

                HStack(spacing: gap) {
                    // Tile 3 — Consultation (amber/gold)
                    AppTile(
                        color1: Color(red: 0.88, green: 0.60, blue: 0.06),
                        color2: Color(red: 1.00, green: 0.80, blue: 0.20),
                        icon:   "stethoscope",
                        title:  "Consultation",
                        line1:  vm.mode.title,
                        line2:  "Tap to explore 3 AI modes",
                        showDot: true,
                        size:   side
                    ) { showModeSheet = true }

                    // Tile 4 — Today's Input (emerald)
                    AppTile(
                        color1: Color(red: 0.06, green: 0.60, blue: 0.42),
                        color2: Color(red: 0.18, green: 0.82, blue: 0.58),
                        icon:   "fork.knife",
                        title:  "Today's Input",
                        line1:  vm.todayInput.hasAnyData
                                    ? "\(vm.todayInput.totalCalories) kcal logged"
                                    : "Log meals & fitness",
                        line2:  vm.todayInput.hasAnyData
                                    ? "\(vm.todayInput.waterGlasses) glasses · \(vm.todayInput.workoutMinutes) min"
                                    : "Track your daily progress",
                        showDot: vm.todayInput.hasAnyData,
                        size:   side
                    ) { showTodayInput = true }
                }
            }
        }
        // Height = 2 tiles + 1 gap
        .frame(height: tileSize * 2 + 14)
    }

    // approximate tile size for frame reservation
    private var tileSize: CGFloat {
        (UIScreen.main.bounds.width - 18 * 2 - 14) / 2
    }

    // MARK: - View Blueprint

    private var viewBlueprintButton: some View {
        Button { vm.showReport = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gold.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gold)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Health Blueprint")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Report · Re-consultation · Meal & Fitness Plan")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gold.opacity(0.6))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gold.opacity(0.3), lineWidth: 1)
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
                            .tint(.black.opacity(0.65))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: vm.report.isEmpty ? "sparkles" : "arrow.clockwise")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(vm.isStreaming ? "Analyzing…"
                         : vm.report.isEmpty ? "Generate Elite Health Blueprint"
                         : "Re-generate Blueprint")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Group {
                        if vm.hasMinimalData {
                            LinearGradient(
                                colors: [Color(red: 0.62, green: 0.46, blue: 0.08),
                                         .gold, .goldLight],
                                startPoint: .leading, endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [Color.white.opacity(0.07),
                                         Color.white.opacity(0.07)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        }
                    }
                )
                .cornerRadius(18)
                .foregroundColor(vm.hasMinimalData ? .black.opacity(0.8) : .init(white: 0.32))
                .shadow(color: vm.hasMinimalData ? Color.gold.opacity(0.35) : .clear,
                        radius: 12, x: 0, y: 5)
            }
            .disabled(!vm.hasMinimalData || vm.isStreaming)

            if !vm.hasMinimalData {
                Text("Fill in Patient Profile or Lab Report to begin")
                    .font(.caption2)
                    .foregroundColor(.init(white: 0.32))
            }
        }
    }

    // MARK: - Disclaimer

    private var disclaimer: some View {
        Text("For health optimization guidance only · Not a substitute for professional medical care")
            .font(.caption2)
            .foregroundColor(.init(white: 0.26))
            .multilineTextAlignment(.center)
    }
}

// MARK: - App Tile

struct AppTile: View {
    let color1:  Color
    let color2:  Color
    let icon:    String
    let title:   String
    let line1:   String
    let line2:   String
    var showDot: Bool   = false
    let size:    CGFloat
    let action:  () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                // Background gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [color1, color2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Soft sheen at top-left
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.22), Color.clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size * 0.75
                        )
                    )

                // Active dot (top-right)
                if showDot {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 8, height: 8)
                        .padding(14)
                }

                // Content
                VStack(spacing: 0) {
                    Spacer()

                    // Icon — visually about half the tile height
                    Image(systemName: icon)
                        .font(.system(size: size * 0.30, weight: .light))
                        .foregroundColor(.white.opacity(0.95))
                        .frame(height: size * 0.38)

                    Spacer()

                    // Text block pinned to bottom
                    VStack(spacing: 5) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)

                        Text(line1)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)

                        Text(line2)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.62))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                    .padding(.bottom, 16)
                    .padding(.horizontal, 10)
                }
                .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: color1.opacity(0.45), radius: 14, x: 0, y: 7)
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
                Color(red: 0.08, green: 0.08, blue: 0.12).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        Text("Choose how the AI approaches your consultation.\nNo medications are ever recommended.")
                            .font(.subheadline)
                            .foregroundColor(.init(white: 0.48))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.horizontal, 20)

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

    private func modeCard(_ mode: ConsultationMode) -> some View {
        let selected = vm.mode == mode
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                vm.mode = mode
            }
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(mode.accentColor.opacity(selected ? 0.28 : 0.12))
                        .frame(width: 56, height: 56)
                    Text(mode.emoji)
                        .font(.system(size: 30))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.init(white: 0.50))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(selected ? mode.accentColor : Color.white.opacity(0.2),
                                lineWidth: 2)
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
                          ? mode.accentColor.opacity(0.10)
                          : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(selected
                                    ? mode.accentColor.opacity(0.55)
                                    : Color.white.opacity(0.07),
                                    lineWidth: selected ? 1.5 : 1)
                    )
            )
            .shadow(color: selected ? mode.accentColor.opacity(0.22) : .clear,
                    radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(ConsultationViewModel())
}
