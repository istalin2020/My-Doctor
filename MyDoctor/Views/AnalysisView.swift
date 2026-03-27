import SwiftUI

// MARK: - Analysis View

struct AnalysisView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.navyDark.ignoresSafeArea()

            if vm.isStreaming && vm.report.isEmpty {
                loadingView
            } else {
                reportScrollView
            }
        }
        .navigationTitle("Health Blueprint")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    vm.reset()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("New")
                    }
                    .foregroundColor(.gold)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !vm.isStreaming && !vm.report.isEmpty {
                    ShareLink(item: vm.report) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gold)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach([0, 1, 2], id: \.self) { i in
                    Circle()
                        .stroke(Color.gold.opacity(0.2 - Double(i) * 0.05), lineWidth: 1)
                        .frame(width: CGFloat(60 + i * 24), height: CGFloat(60 + i * 24))
                        .scaleEffect(vm.isStreaming ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever().delay(Double(i) * 0.3), value: vm.isStreaming)
                }
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gold)
            }

            VStack(spacing: 6) {
                Text("Analyzing Your Health Data")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("The Sovereign Physician is compiling\nyour elite health blueprint")
                    .font(.subheadline)
                    .foregroundColor(.init(white: 0.45))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                ForEach([
                    "Mapping biomarkers against optimal ranges...",
                    "Analyzing regional dietary factors...",
                    "Synthesizing performance protocols...",
                    "Generating longevity insights...",
                ], id: \.self) { phase in
                    HStack(spacing: 8) {
                        Circle().fill(Color.gold).frame(width: 4, height: 4)
                        Text(phase)
                            .font(.caption)
                            .foregroundColor(.init(white: 0.4))
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 40)

            Text("Powered by OpenAI — gpt-4o")
                .font(.caption2)
                .foregroundColor(.init(white: 0.25))
        }
    }

    // MARK: - Report

    private var reportScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MarkdownDocument(content: vm.report, isStreaming: vm.isStreaming)
                        .padding(20)

                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
            }
            .onChange(of: vm.report) { _ in
                if vm.isStreaming {
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
        }
    }
}

// MARK: - Markdown Document Renderer

struct MarkdownDocument: View {
    let content: String
    let isStreaming: Bool

    private var lines: [String] { content.components(separatedBy: "\n") }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                lineView(line)
            }
            if isStreaming {
                HStack {
                    Text("▋")
                        .foregroundColor(.gold)
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isStreaming)
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private func lineView(_ line: String) -> some View {
        if line.hasPrefix("## ") {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(line.dropFirst(3)))
                    .font(.title3.bold())
                    .foregroundStyle(LinearGradient(colors: [.gold, .goldLight], startPoint: .leading, endPoint: .trailing))
                    .padding(.top, 20)
                Divider()
                    .overlay(Color.gold.opacity(0.25))
            }
        } else if line.hasPrefix("### ") {
            Text(String(line.dropFirst(4)))
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 10)
        } else if line.hasPrefix("---") || line.hasPrefix("═══") {
            Divider().overlay(Color.white.opacity(0.1)).padding(.vertical, 6)
        } else if line.hasPrefix("- ") || line.hasPrefix("• ") || line.hasPrefix("* ") {
            bulletLine(String(line.dropFirst(2)))
        } else if let numbered = extractNumberedLine(line) {
            numberedLine(numbered.number, text: numbered.text)
        } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
            inlineText(line)
                .padding(.bottom, 2)
        }
    }

    private func bulletLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("▸")
                .foregroundColor(.gold)
                .font(.subheadline)
                .frame(width: 14)
            inlineText(text)
            Spacer(minLength: 0)
        }
    }

    private func numberedLine(_ n: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.gold.opacity(0.15))
                    .frame(width: 22, height: 22)
                Text("\(n)")
                    .font(.caption2.bold())
                    .foregroundColor(.gold)
            }
            inlineText(text)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func inlineText(_ raw: String) -> some View {
        if let attributed = buildAttributed(raw) {
            Text(attributed)
                .font(.subheadline)
                .foregroundColor(Color(white: 0.78))
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(raw)
                .font(.subheadline)
                .foregroundColor(Color(white: 0.78))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helpers

    private func extractNumberedLine(_ line: String) -> (number: Int, text: String)? {
        let parts = line.split(separator: ".", maxSplits: 1)
        guard parts.count == 2,
              let n = Int(parts[0].trimmingCharacters(in: .whitespaces)) else { return nil }
        return (n, String(parts[1]).trimmingCharacters(in: .whitespaces))
    }

    private func buildAttributed(_ raw: String) -> AttributedString? {
        // Wrap with markdown support for **bold** and *italic*
        let prepared = raw
            .replacingOccurrences(of: "🟢 OPTIMAL",      with: "**🟢 OPTIMAL**")
            .replacingOccurrences(of: "🟡 SUB-OPTIMAL",  with: "**🟡 SUB-OPTIMAL**")
            .replacingOccurrences(of: "🔴 CRITICAL",     with: "**🔴 CRITICAL**")
            .replacingOccurrences(of: "🔴 ELEVATED",     with: "**🔴 ELEVATED**")
            .replacingOccurrences(of: "🔴 LOW",          with: "**🔴 LOW**")
        return try? AttributedString(
            markdown: prepared,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
    }
}

#Preview {
    AnalysisView()
        .environmentObject({
            let vm = ConsultationViewModel()
            vm.report = """
            ## 🏥 Medical State of the Union

            You are operating at sub-optimal metabolic capacity. Multiple biomarkers indicate insulin resistance progression and elevated cardiovascular risk.

            ## 🔬 Biomarker Breakdown

            **HbA1c**: 5.8% → Optimal: < 5.4% — Status: 🟡 SUB-OPTIMAL
            **LDL-C**: 140 mg/dL → Optimal: < 70 mg/dL — Status: 🔴 CRITICAL
            **Vitamin D**: 22 ng/mL → Optimal: 60–80 ng/mL — Status: 🔴 CRITICAL

            ## ✅ Daily Non-Negotiables

            1. Take 5000 IU Vitamin D3 + 100mcg K2 with your largest meal every morning.
            2. Walk 45 minutes at Zone 2 heart rate (115–130 bpm) before 10am on an empty stomach.
            3. Eliminate all rice and roti from dinner. Replace with 200g sautéed vegetables + 150g dal.
            """
            return vm
        }())
}
