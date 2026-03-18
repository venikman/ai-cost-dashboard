import Foundation

public struct LiteLLMDataSource: Sendable {
    private let jsonURL = URL(string: "https://raw.githubusercontent.com/BerriAI/litellm/main/model_prices_and_context_window.json")!

    public init() {}

    public func fetchModels() async throws -> [AIModel] {
        var request = URLRequest(url: jsonURL)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.badResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decodingFailed("Expected JSON dictionary")
        }

        var models: [AIModel] = []

        for (key, value) in json {
            guard let entry = value as? [String: Any],
                  let mode = entry["mode"] as? String, mode == "chat",
                  let inputCost = entry["input_cost_per_token"] as? Double,
                  let outputCost = entry["output_cost_per_token"] as? Double,
                  inputCost > 0 || outputCost > 0 else {
                continue
            }

            let litellmProvider = entry["litellm_provider"] as? String ?? ""
            guard let provider = Self.mapProvider(litellmProvider) else { continue }

            let inputPer1M = inputCost * 1_000_000
            let outputPer1M = outputCost * 1_000_000

            let maxInput = entry["max_input_tokens"] as? Int ?? entry["max_tokens"] as? Int ?? 0
            let maxOutput = entry["max_output_tokens"] as? Int

            let (name, family, normalizedId) = Self.parseModelKey(key, provider: provider)

            // Skip entries that don't map to recognizable models
            guard !name.isEmpty else { continue }

            let providerPrice = ProviderPrice(
                provider: provider,
                inputPer1M: inputPer1M,
                outputPer1M: outputPer1M
            )

            let model = AIModel(
                id: normalizedId,
                name: name,
                family: family,
                providers: [providerPrice],
                contextWindow: maxInput,
                maxOutput: maxOutput,
                speed: nil
            )
            models.append(model)
        }

        return models
    }

    private static func mapProvider(_ litellmProvider: String) -> Provider? {
        let lower = litellmProvider.lowercased()
        if lower.contains("bedrock") {
            return .bedrock
        } else if lower.contains("vertex") {
            return .vertex
        } else if lower.contains("azure") {
            return .azure
        } else if lower == "anthropic" || lower == "anthropic_text" {
            return .anthropic
        } else if lower == "openai" || lower == "text-completion-openai" {
            return .openai
        } else if lower == "gemini" || lower == "google_ai_studio" {
            return .google
        }
        return nil // Skip providers we don't track
    }

    private static func parseModelKey(_ key: String, provider: Provider) -> (name: String, family: String, normalizedId: String) {
        // LiteLLM keys look like: "claude-sonnet-4-20250514", "gpt-4o", "gemini/gemini-2.0-flash"
        // Or with provider prefix: "bedrock/anthropic.claude-sonnet-4-v1"

        var modelPart = key

        // Strip everything before the last "/" (handles bedrock/, vertex_ai/, azure/eu/, etc.)
        if modelPart.contains("/") {
            let parts = modelPart.split(separator: "/")
            if let last = parts.last {
                modelPart = String(last)
            }
        }

        // Strip provider.vendor prefixes like "anthropic.", "amazon.", "meta.", "mistral.", "cohere."
        // Also handles regional prefixes: "apac.anthropic.", "au.anthropic.", "eu.anthropic.",
        // "apac.amazon.", "us.amazon.", etc.
        let vendorPrefixPattern = #"^(?:[a-z]{2,4}\.)?(?:anthropic|amazon|meta|mistral|cohere|ai21)\."#
        if let regex = try? NSRegularExpression(pattern: vendorPrefixPattern, options: .caseInsensitive) {
            let range = NSRange(modelPart.startIndex..., in: modelPart)
            modelPart = regex.stringByReplacingMatches(in: modelPart, range: range, withTemplate: "")
        }

        // Strip version/date suffixes: "-20250514", "-v1", "-v2:0", "@20240307"
        let versionPattern = #"[-@]\d{8}$|-v\d+.*$|:\d+$"#
        if let regex = try? NSRegularExpression(pattern: versionPattern) {
            let range = NSRange(modelPart.startIndex..., in: modelPart)
            modelPart = regex.stringByReplacingMatches(in: modelPart, range: range, withTemplate: "")
        }

        let normalizedId = modelPart.lowercased()

        // Build display name
        let name = Self.humanizeName(modelPart)
        let family = Self.deriveFamily(name)

        return (name, family, normalizedId)
    }

    private static func humanizeName(_ raw: String) -> String {
        var name = raw
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")

        // Remove trailing 8-digit date (e.g., "20240229") or @date patterns
        if let regex = try? NSRegularExpression(pattern: #"\s*@?\d{8}\s*$"#) {
            let range = NSRange(name.startIndex..., in: name)
            name = regex.stringByReplacingMatches(in: name, range: range, withTemplate: "")
        }

        // Capitalize intelligently
        let words = name.split(separator: " ").map { word -> String in
            let w = String(word)
            let lower = w.lowercased()

            // Keep known abbreviations uppercase
            if ["gpt", "o1", "o3", "o4", "4o", "4.1"].contains(lower) {
                return w.uppercased()
            }

            // Capitalize first letter
            return w.prefix(1).uppercased() + w.dropFirst()
        }

        name = words.joined(separator: " ")
        return name
    }

    private static func deriveFamily(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("claude") { return "Claude" }
        if lower.contains("gpt") || lower.contains("o1") || lower.contains("o3") || lower.contains("o4") { return "GPT" }
        if lower.contains("gemini") { return "Gemini" }
        if lower.contains("deepseek") { return "DeepSeek" }
        if lower.contains("mistral") || lower.contains("mixtral") { return "Mistral" }
        if lower.contains("llama") { return "Llama" }
        if lower.contains("command") { return "Cohere" }
        return "Other"
    }
}
