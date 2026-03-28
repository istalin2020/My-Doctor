import Foundation
import UIKit

enum OpenAIService {

    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: "openai_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "openai_api_key") }
    }

    // MARK: - Streaming Chat (Sovereign Physician analysis)

    static func stream(system: String, user: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard !apiKey.isEmpty else { throw APIError.missingKey }

                    var request = URLRequest(url: endpoint)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json",  forHTTPHeaderField: "Content-Type")

                    let body: [String: Any] = [
                        "model": "gpt-4o",
                        "max_tokens": 4096,
                        "stream": true,
                        "messages": [
                            ["role": "system", "content": system],
                            ["role": "user",   "content": user],
                        ],
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
                    guard http.statusCode == 200 else { throw APIError.httpError(http.statusCode) }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                        if payload == "[DONE]" { break }

                        guard
                            let data    = payload.data(using: .utf8),
                            let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let choices = json["choices"] as? [[String: Any]],
                            let delta   = choices.first?["delta"] as? [String: Any],
                            let text    = delta["content"] as? String
                        else { continue }

                        continuation.yield(text)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Vision: Lab Report Extraction

    /// Sends one or more lab-report images to GPT-4o Vision and returns a
    /// dictionary of field-name → numeric value strings, e.g. ["HbA1c": "5.8"].
    static func extractLabValues(from images: [UIImage]) async throws -> [String: String] {
        guard !apiKey.isEmpty else { throw APIError.missingKey }
        guard !images.isEmpty else { return [:] }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        // Build the content array: one image block per page + one text block
        var contentBlocks: [[String: Any]] = []

        for image in images.prefix(3) {           // max 3 pages to stay within token limits
            let compressed = image.jpegData(compressionQuality: 0.6) ?? Data()
            let b64 = compressed.base64EncodedString()
            contentBlocks.append([
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(b64)",
                    "detail": "high",
                ],
            ])
        }

        contentBlocks.append([
            "type": "text",
            "text": extractionPrompt,
        ])

        let body: [String: Any] = [
            "model": "gpt-4o",
            "max_tokens": 800,
            "messages": [
                ["role": "user", "content": contentBlocks],
            ],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard http.statusCode == 200 else { throw APIError.httpError(http.statusCode) }

        guard
            let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw APIError.invalidResponse }

        return parseExtractedJSON(content)
    }

    // MARK: - Private helpers

    private static let extractionPrompt = """
    You are a precise medical lab report parser.

    Extract every laboratory test result visible in the image(s).

    Return ONLY a valid JSON object — no markdown, no explanation — in this exact format:
    {
      "values": {
        "HbA1c": "5.8",
        "Fasting Glucose": "95"
      }
    }

    Use ONLY these exact field names (omit any not found):
    Fasting Glucose, HbA1c, Fasting Insulin, HOMA-IR,
    Total Cholesterol, LDL-C, HDL-C, Triglycerides, Lp(a), ApoB,
    Hemoglobin, WBC, Platelets, MCV,
    ALT (SGPT), AST (SGOT), GGT, Creatinine, eGFR, Uric Acid,
    TSH, Free T3, Free T4,
    Total Testosterone, DHEA-S, Cortisol (AM), IGF-1,
    Vitamin D (25-OH), Vitamin B12, Ferritin, Magnesium (RBC), Zinc,
    hsCRP, Homocysteine, ESR.

    Values must be numeric strings only (no units, no ranges, no symbols).
    If a value is unclear or absent, omit that key entirely.
    Return ONLY the JSON object.
    """

    private static func parseExtractedJSON(_ raw: String) -> [String: String] {
        // Strip any markdown code fences the model might add
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Find the outermost {...}
        guard
            let start = cleaned.firstIndex(of: "{"),
            let end   = cleaned.lastIndex(of: "}"),
            start <= end
        else { return [:] }

        let jsonSlice = String(cleaned[start...end])

        guard
            let data   = jsonSlice.data(using: .utf8),
            let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let values = json["values"] as? [String: Any]
        else { return [:] }

        return values.compactMapValues { $0 as? String }
    }

    // MARK: - Errors

    enum APIError: LocalizedError {
        case missingKey
        case invalidResponse
        case httpError(Int)

        var errorDescription: String? {
            switch self {
            case .missingKey:
                return "OpenAI API key is not set. Tap ⚙️ Settings to add your key."
            case .invalidResponse:
                return "Received an invalid response from the OpenAI API."
            case .httpError(let code):
                return "API request failed (HTTP \(code)). Check your API key and quota."
            }
        }
    }
}
