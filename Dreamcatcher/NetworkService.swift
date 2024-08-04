import UIKit

protocol NetworkServiceProtocol {
    func generateTags(prompt: String) async throws -> [String]
    func generateDreamImage(prompt: String) async throws -> UIImage
}

final class NetworkService: NetworkServiceProtocol {

    func generateTags(prompt: String) async throws -> [String] {
        let url = URL(string: "https://dreamcatcher-tag-generator.guitaripod.workers.dev/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["dreamPrompt": prompt]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        let tags = try JSONDecoder().decode([String].self, from: data)
        return tags.filter { !$0.isEmpty }
    }

    func generateDreamImage(prompt: String) async throws -> UIImage {
        let url = URL(string: "https://dream-image-generator.guitaripod.workers.dev")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["prompt": prompt]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "Image Error", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])
        }

        return image
    }
}
