import SwiftUI

struct ModeSelectorView: View {
    @EnvironmentObject var vm: ConsultationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONSULTATION MODE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.init(white: 0.4))
                .kerning(1.2)

            VStack(spacing: 8) {
                ForEach(ConsultationMode.allCases) { mode in
                    modeCard(mode)
                }
            }
        }
    }

    private func modeCard(_ mode: ConsultationMode) -> some View {
        let selected = vm.mode == mode
        return Button { vm.mode = mode } label: {
            HStack(spacing: 12) {
                Text(mode.emoji)
                    .font(.title3)
                    .frame(width: 36, height: 36)
                    .background(mode.accentColor.opacity(0.15))
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(selected ? mode.accentColor : Color.white.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if selected {
                        Circle()
                            .fill(mode.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(12)
            .background(selected ? mode.accentColor.opacity(0.08) : Color.navyCard)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? mode.accentColor.opacity(0.5) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .cornerRadius(12)
        }
    }
}

#Preview {
    ModeSelectorView()
        .environmentObject(ConsultationViewModel())
        .padding()
        .background(Color.navyDark)
}
