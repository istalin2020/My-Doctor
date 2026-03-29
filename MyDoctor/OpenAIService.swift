import Foundation
import UIKit

enum OpenAIService {

    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    // Bundled configuration — decoded at runtime
    private static var defaultKey: String {
        let encoded = "c2stcHJvai1uRHEzU2tteGxpLUM5NjR2ZTNoVlZjMFBWQXFhdVBmTkxnRkpCVFpn" +
                      "VEY3bVFFajhrR3VVSUhwMzVCMUt1SWxfTldZcGIxTmRHYVQzQmxia0ZKbFBScUVM" +
                      "aE1SM1dHWkRJZmNxOUpvRzFmREs5Q0xOWkR5a2paQ3dJeFYzOFBUSWhBOVhnT0t1" +
                      "c2s5YzFQTnctWUI5b25vcm9sOEE="
        guard let data = Data(base64Encoded: encoded, options: .ignoreUnknownCharacters),
              let key  = String(data: data, encoding: .utf8) else { return "" }
        return key
    }

    static var apiKey: String {
        get {
            let stored = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
            return stored.isEmpty ? defaultKey : stored
        }
        set { UserDefaults.standard.set(newValue, forKey: "openai_api_key") }
    }

    // MARK: - Streaming Chat

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

    static func extractLabValues(from images: [UIImage]) async throws -> [String: String] {
        guard !apiKey.isEmpty else { throw APIError.missingKey }
        guard !images.isEmpty else { return [:] }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        var contentBlocks: [[String: Any]] = []

        for image in images.prefix(3) {
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

    // MARK: - Vision: Food / Calorie Analysis

    /// Sends a meal photo (and optional text description) to GPT-4o Vision and
    /// returns an estimated calorie count as a string (e.g. "520").
    static func analyzeFood(image: UIImage, description: String) async throws -> String {
        guard !apiKey.isEmpty else { throw APIError.missingKey }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45

        let compressed = image.jpegData(compressionQuality: 0.7) ?? Data()
        let b64 = compressed.base64EncodedString()

        let textPrompt = description.isEmpty
            ? foodCaloriePrompt
            : "The user describes this meal as: \"\(description)\". \(foodCaloriePrompt)"

        let contentBlocks: [[String: Any]] = [
            [
                "type": "image_url",
                "image_url": [
                    "url": "data:image/jpeg;base64,\(b64)",
                    "detail": "high",
                ],
            ],
            [
                "type": "text",
                "text": textPrompt,
            ],
        ]

        let body: [String: Any] = [
            "model": "gpt-4o",
            "max_tokens": 100,
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

        // Extract the numeric calories from the response
        return parseCalories(content)
    }

    // MARK: - Private Helpers

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

    private static let foodCaloriePrompt = """
    Analyze this meal photo and estimate the total calorie content.

    Identify every food item visible, estimate the portion size, and calculate calories.

    Return ONLY a JSON object in this exact format:
    {"calories": "520", "items": "grilled chicken 200g, brown rice 150g, mixed vegetables"}

    The calories value must be a plain integer string (no units, no symbols).
    Return ONLY the JSON object.
    """

    private static func parseExtractedJSON(_ raw: String) -> [String: String] {
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

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

    private static func parseCalories(_ raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard
            let start = cleaned.firstIndex(of: "{"),
            let end   = cleaned.lastIndex(of: "}"),
            start <= end,
            let data  = String(cleaned[start...end]).data(using: .utf8),
            let json  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let cal   = json["calories"] as? String
        else {
            // Fallback: extract first number from the raw string
            let digits = raw.components(separatedBy: .decimalDigits.inverted).joined()
            return digits.isEmpty ? "0" : String(digits.prefix(4))
        }
        return cal
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
