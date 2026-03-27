import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = OpenAIService.apiKey
    @State private var showKey = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()

                Form {
                    Section {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.gold)
                            if showKey {
                                TextField("sk-...", text: $apiKey)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.white)
                            } else {
                                SecureField("sk-...", text: $apiKey)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            Button {
                                showKey.toggle()
                            } label: {
                                Image(systemName: showKey ? "eye.slash" : "eye")
                                    .foregroundColor(.init(white: 0.4))
                            }
                        }
                    } header: {
                        Text("OpenAI API Key")
                            .foregroundColor(.gold)
                            .font(.footnote.weight(.semibold))
                            .textCase(nil)
                    } footer: {
                        Text("Your key is stored locally on this device via UserDefaults. It is never transmitted to any server other than api.openai.com.")
                            .font(.caption)
                            .foregroundColor(.init(white: 0.35))
                    }

                    Section {
                        infoRow(icon: "brain.head.profile", label: "AI Model", value: "gpt-4o")
                        infoRow(icon: "iphone", label: "App Version", value: "1.0.0")
                        infoRow(icon: "cross.fill", label: "Consultation Modes", value: "3")
                        infoRow(icon: "cross.vial", label: "Biomarker Panels", value: "8 panels / 40+ markers")
                    } header: {
                        Text("App Info")
                            .foregroundColor(.gold)
                            .font(.footnote.weight(.semibold))
                            .textCase(nil)
                    }

                    Section {
                        Text("⚠️ This app is for health optimization guidance only. It does not replace in-person emergency medical care. Always consult a licensed physician for diagnosis and treatment.")
                            .font(.caption)
                            .foregroundColor(.init(white: 0.4))
                    } header: {
                        Text("Disclaimer")
                            .foregroundColor(.gold)
                            .font(.footnote.weight(.semibold))
                            .textCase(nil)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        OpenAIService.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                    .foregroundColor(.gold)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.init(white: 0.5))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gold)
                .frame(width: 20)
            Text(label).foregroundColor(.init(white: 0.7))
            Spacer()
            Text(value)
                .foregroundColor(.init(white: 0.45))
                .font(.subheadline)
        }
    }
}

#Preview {
    SettingsView()
}
