import Foundation

struct ChatRequest: Codable { let sessionId: String; let message: String }
struct ChatResponse: Codable { let reply: String }

enum APIError: Error { case badURL, badResponse }

final class APIClient {
    // Change this to your deployed backend, e.g. https://your-service.example.com
    static var baseURL = "http://127.0.0.1:8787"

    static func ask(_ message: String, sessionId: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat") else { throw APIError.badURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 45
        req.httpBody = try JSONEncoder().encode(ChatRequest(sessionId: sessionId, message: message))
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw APIError.badResponse }
        return try JSONDecoder().decode(ChatResponse.self, from: data).reply
    }
}
