import Foundation

public struct OpenRouterAPI: Sendable {
    private let modelsURL = URL(string: "https://openrouter.ai/api/v1/models")!

    public init() {}

    public func fetchModels() async throws -> [AIModel] {
        var request = URLRequest(url: modelsURL)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.badResponse
        }

        let decoded = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        return decoded.data.compactMap { model in
            // Skip non-chat models and free models with zero pricing
            guard let promptPrice = Double(model.pricing.prompt ?? "0"),
                  let completionPrice = Double(model.pricing.completion ?? "0"),
                  (promptPrice > 0 || completionPrice > 0) else {
                return nil
            }

            let inputPer1M = promptPrice * 1_000_000
            let outputPer1M = completionPrice * 1_000_000

            let providerPrice = ProviderPrice(
                provider: .openRouter,
                inputPer1M: inputPer1M,
                outputPer1M: outputPer1M
            )

            let (name, family) = Self.parseModelName(model.name, id: model.id)

            return AIModel(
                id: model.id,
                name: name,
                family: family,
                providers: [providerPrice],
                contextWindow: model.context_length ?? model.top_provider?.context_length ?? 0,
                maxOutput: model.top_provider?.max_completion_tokens,
                speed: nil
            )
        }
    }

    private static func parseModelName(_ name: String, id: String) -> (name: String, family: String) {
        // OpenRouter names are like "OpenAI: GPT-4o" or "Anthropic: Claude Sonnet 4"
        let cleanName: String
        if let colonIndex = name.firstIndex(of: ":") {
            cleanName = String(name[name.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
        } else {
            cleanName = name
        }

        // Derive family from the model name
        let family: String
        let lowerName = cleanName.lowercased()
        if lowerName.contains("claude") {
            family = "Claude"
        } else if lowerName.contains("gpt") || lowerName.contains("o1") || lowerName.contains("o3") || lowerName.contains("o4") {
            family = "GPT"
        } else if lowerName.contains("gemini") {
            family = "Gemini"
        } else if lowerName.contains("deepseek") {
            family = "DeepSeek"
        } else if lowerName.contains("mistral") || lowerName.contains("mixtral") {
            family = "Mistral"
        } else if lowerName.contains("llama") {
            family = "Llama"
        } else if lowerName.contains("command") {
            family = "Cohere"
        } else {
            family = "Other"
        }

        return (cleanName, family)
    }
}

// MARK: - Response Types

private struct OpenRouterResponse: Decodable {
    let data: [OpenRouterModel]
}

private struct OpenRouterModel: Decodable {
    let id: String
    let name: String
    let pricing: OpenRouterPricing
    let context_length: Int?
    let top_provider: OpenRouterTopProvider?
}

private struct OpenRouterPricing: Decodable {
    let prompt: String?
    let completion: String?
}

private struct OpenRouterTopProvider: Decodable {
    let context_length: Int?
    let max_completion_tokens: Int?
}

public enum APIError: Error, LocalizedError {
    case badResponse
    case decodingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .badResponse: "Server returned an error"
        case .decodingFailed(let msg): "Failed to parse response: \(msg)"
        }
    }
}
