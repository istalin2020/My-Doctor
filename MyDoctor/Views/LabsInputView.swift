import SwiftUI
import PhotosUI
import PDFKit
import UniformTypeIdentifiers

struct LabsInputView: View {
    @EnvironmentObject var vm: ConsultationViewModel
    @Environment(\.dismiss) private var dismiss

    // Upload flow state
    @State private var showSourceMenu    = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showDocumentPicker = false
    @State private var isExtracting      = false
    @State private var extractedValues:  [String: String] = [:]
    @State private var showReview        = false
    @State private var extractionError:  String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.navyDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        uploadCard
                        if isExtracting    { extractingCard }
                        if let err = extractionError { errorBanner(err) }
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
                    Button("Clear All") { vm.labValues = [:] }
                        .foregroundColor(.init(white: 0.4))
                        .font(.subheadline)
                }
            }
            // Source selection sheet
            .confirmationDialog(
                "Upload Lab Report",
                isPresented: $showSourceMenu,
                titleVisibility: .visible
            ) {
                PhotosPicker(
                    selection: $photoPickerItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                }
                Button("PDF Document") { showDocumentPicker = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("AI will auto-extract your biomarker values")
            }
            // Photos picker change handler
            .onChange(of: photoPickerItem) { item in
                guard let item else { return }
                Task {
                    guard let data  = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    await runExtraction(images: [image])
                    photoPickerItem = nil
                }
            }
            // PDF / image file importer
            .fileImporter(
                isPresented: $showDocumentPicker,
                allowedContentTypes: [.pdf, .jpeg, .png, .heic],
                allowsMultipleSelection: false
            ) { result in
                Task {
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else { return }
                        let images = loadImages(from: url)
                        await runExtraction(images: images)
                    case .failure(let err):
                        extractionError = err.localizedDescription
                    }
                }
            }
            // Review sheet
            .sheet(isPresented: $showReview) {
                LabExtractionReviewView(extracted: extractedValues) { confirmed in
                    vm.labValues.merge(confirmed) { _, new in new }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Upload card

    private var uploadCard: some View {
        Button { showSourceMenu = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gold.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "doc.text.viewfinder")
                        .foregroundColor(.gold)
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upload Lab Report")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text("Photo or PDF — AI extracts values instantly")
                        .font(.caption)
                        .foregroundColor(.init(white: 0.45))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gold)
                    .font(.caption.weight(.semibold))
            }
            .padding(14)
            .background(Color.navyCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gold.opacity(0.35), lineWidth: 1)
            )
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Extracting card

    private var extractingCard: some View {
        HStack(spacing: 14) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.gold)
                .scaleEffect(0.9)
            VStack(alignment: .leading, spacing: 2) {
                Text("Analyzing report…")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text("GPT-4o Vision is reading your biomarkers")
                    .font(.caption)
                    .foregroundColor(.init(white: 0.45))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.navyCard)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gold.opacity(0.25), lineWidth: 1))
        .cornerRadius(14)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Error banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.init(white: 0.6))
            Spacer()
            Button { extractionError = nil } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.init(white: 0.4))
                    .font(.caption)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(0.3), lineWidth: 1))
        .cornerRadius(10)
    }

    // MARK: - Tip banner

    private var tipBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡")
            Text("Enter values manually, or upload your report above for instant AI extraction. The Sovereign Physician evaluates against **optimal** ranges, not just \"normal\" ranges.")
                .font(.caption)
                .foregroundColor(.init(white: 0.5))
        }
        .padding(12)
        .background(Color.gold.opacity(0.06))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gold.opacity(0.2), lineWidth: 1))
        .cornerRadius(10)
    }

    // MARK: - Panel card

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

    // MARK: - Field cell

    private func fieldCell(_ field: LabField) -> some View {
        let hasValue = !(vm.labValues[field.key] ?? "").isEmpty
        return VStack(alignment: .leading, spacing: 4) {
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
                    .stroke(hasValue ? Color.gold.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(8)

            Text("Optimal: \(field.optimal)")
                .font(.caption2)
                .foregroundColor(.init(white: 0.3))
        }
    }

    // MARK: - Extraction logic

    @MainActor
    private func runExtraction(images: [UIImage]) async {
        guard !images.isEmpty else {
            extractionError = "Could not read the selected file."
            return
        }
        withAnimation { isExtracting = true }
        extractionError = nil

        do {
            let result = try await OpenAIService.extractLabValues(from: images)
            if result.isEmpty {
                extractionError = "No lab values detected. Try a clearer, higher-resolution image."
            } else {
                extractedValues = result
                showReview = true
            }
        } catch {
            extractionError = error.localizedDescription
        }

        withAnimation { isExtracting = false }
    }

    /// Load images from a URL (PDF pages or direct image file).
    private func loadImages(from url: URL) -> [UIImage] {
        guard url.startAccessingSecurityScopedResource() else { return [] }
        defer { url.stopAccessingSecurityScopedResource() }

        if url.pathExtension.lowercased() == "pdf" {
            return renderPDFPages(url: url)
        } else if let data  = try? Data(contentsOf: url),
                  let image = UIImage(data: data) {
            return [image]
        }
        return []
    }

    /// Renders the first 3 pages of a PDF as UIImages (2× scale for OCR quality).
    private func renderPDFPages(url: URL) -> [UIImage] {
        guard let pdf = PDFDocument(url: url) else { return [] }
        var images: [UIImage] = []
        let pageCount = min(pdf.pageCount, 3)

        for i in 0..<pageCount {
            guard let page = pdf.page(at: i) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let scale:  CGFloat = 2.0
            let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)

            let renderer = UIGraphicsImageRenderer(size: size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(CGRect(origin: .zero, size: size))
                ctx.cgContext.translateBy(x: 0, y: size.height)
                ctx.cgContext.scaleBy(x: scale, y: -scale)
                page.draw(with: .mediaBox, to: ctx.cgContext)
            }
            images.append(img)
        }
        return images
    }
}

#Preview {
    LabsInputView().environmentObject(ConsultationViewModel())
}
