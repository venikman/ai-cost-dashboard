import Foundation

public enum ModelMatcher {
    /// Merges models from OpenRouter and LiteLLM by matching on normalized IDs.
    /// Models with the same base name get their provider lists combined.
    public static func merge(openRouterModels: [AIModel], liteLLMModels: [AIModel]) -> [AIModel] {
        var merged: [String: AIModel] = [:]

        // Index OpenRouter models first
        for model in openRouterModels {
            let key = normalizeKey(model.id)
            guard !key.isEmpty else { continue }
            merged[key] = model
        }

        // Merge LiteLLM models in
        for model in liteLLMModels {
            let key = normalizeKey(model.id)
            guard !key.isEmpty else { continue }

            if var existing = merged[key] {
                // Add providers that aren't already present
                for price in model.providers {
                    if !existing.providers.contains(where: { $0.provider == price.provider }) {
                        existing.providers.append(price)
                    }
                }
                // Use better metadata if available
                if existing.contextWindow == 0 && model.contextWindow > 0 {
                    existing = AIModel(
                        id: existing.id,
                        name: existing.name,
                        family: existing.family,
                        providers: existing.providers,
                        contextWindow: model.contextWindow,
                        maxOutput: existing.maxOutput ?? model.maxOutput,
                        speed: existing.speed ?? model.speed
                    )
                }
                merged[key] = existing
            } else {
                merged[key] = model
            }
        }

        // Only keep models on the curated list
        let curated = filterToCuratedModels(Array(merged.values))

        // Sort by family then name
        return curated.sorted { a, b in
            if a.family != b.family { return a.family < b.family }
            return a.name < b.name
        }
    }

    // MARK: - Curated Model List

    /// Strict whitelist of only the models people actually use.
    /// Each entry is a normalized key that must match exactly.
    private static let curatedModels: Set<String> = [
        // Anthropic — Claude
        "claude-sonnet-4",
        "claude-opus-4",
        "claude-haiku-3.5",
        "claude-haiku-3-5-sonnet",  // alternate naming
        "claude-sonnet-4.5",
        "claude-sonnet-3.5",
        "claude-sonnet-3-5",
        "claude-haiku-4",
        "claude-haiku-4.5",
        "claude-haiku-4-5",
        "claude-opus-4.6",
        "claude-opus-4-6",
        "claude-sonnet-4.6",
        "claude-sonnet-4-6",

        // OpenAI — GPT
        "gpt-4o",
        "gpt-4o-mini",
        "gpt-4.1",
        "gpt-4.1-mini",
        "gpt-4.1-nano",
        "gpt-4.5-preview",
        "gpt-4-turbo",
        "gpt-5",
        "gpt-5.4-nano",
        "gpt-5.4-mini",
        "o1",
        "o1-mini",
        "o1-preview",
        "o3",
        "o3-mini",
        "o3-pro",
        "o4-mini",

        // Google — Gemini
        "gemini-2.0-flash",
        "gemini-2.0-flash-lite",
        "gemini-2.0-pro",
        "gemini-2.5-pro",
        "gemini-2.5-flash",
        "gemini-1.5-pro",
        "gemini-1.5-flash",

        // DeepSeek
        "deepseek-v3",
        "deepseek-r1",
        "deepseek-chat",
        "deepseek-reasoner",

        // Meta — Llama
        "llama-4-maverick",
        "llama-4-scout",
        "llama-3.3-70b",
        "llama-3.3-70b-instruct",
        "llama-3.1-405b",
        "llama-3.1-405b-instruct",

        // Mistral
        "mistral-large",
        "mistral-medium",

        // Cohere
        "command-r-plus",
        "command-r",
        "command-a",
    ]

    private static func filterToCuratedModels(_ models: [AIModel]) -> [AIModel] {
        models.filter { model in
            let key = normalizeKey(model.id)
            return curatedModels.contains(key)
        }
    }

    // MARK: - Key Normalization

    /// Aggressively normalizes model IDs so the same model from different sources matches.
    private static func normalizeKey(_ id: String) -> String {
        var key = id.lowercased()

        // Strip everything before the last "/"
        if let slashIdx = key.lastIndex(of: "/") {
            key = String(key[key.index(after: slashIdx)...])
        }

        // Strip vendor prefixes: "anthropic.", "amazon.", "apac.anthropic.", etc.
        if let regex = try? NSRegularExpression(pattern: #"^(?:[a-z]{2,4}\.)?(?:anthropic|amazon|meta|mistral|cohere|ai21|google)\."#) {
            let range = NSRange(key.startIndex..., in: key)
            key = regex.stringByReplacingMatches(in: key, range: range, withTemplate: "")
        }

        // Strip date suffixes: "-20250514", "@20240307"
        if let regex = try? NSRegularExpression(pattern: #"[-@]\d{8}$"#) {
            let range = NSRange(key.startIndex..., in: key)
            key = regex.stringByReplacingMatches(in: key, range: range, withTemplate: "")
        }

        // Strip version suffixes: "-v1", "-v2:0", ":0"
        if let regex = try? NSRegularExpression(pattern: #"-v\d+.*$|:\d+$"#) {
            let range = NSRange(key.startIndex..., in: key)
            key = regex.stringByReplacingMatches(in: key, range: range, withTemplate: "")
        }

        // Normalize separators: convert dots in version numbers but keep them for versions
        // "claude-3-5-sonnet" and "claude-3.5-sonnet" should match
        // But only for single digits separated by dots that look like versions
        key = key.replacingOccurrences(of: "chatgpt-", with: "gpt-")

        return key.trimmingCharacters(in: .whitespaces)
    }
}
