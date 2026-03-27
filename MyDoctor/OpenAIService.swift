import Foundation

enum OpenAIService {

    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    static var apiKey: String {
        get { UserDefaults.standard.string(forKey: "openai_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "openai_api_key") }
    }

    // Returns an AsyncThrowingStream that yields each text token as it arrives.
    static func stream(system: String, user: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard !apiKey.isEmpty else {
                        throw APIError.missingKey
                    }

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

                    guard let http = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }
                    guard http.statusCode == 200 else {
                        throw APIError.httpError(http.statusCode)
                    }

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
                return "API request failed (HTTP \(code)). Check your API key and account quota."
            }
        }
    }
}
