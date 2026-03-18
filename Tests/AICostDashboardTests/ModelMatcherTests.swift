import Testing
@testable import AICostDashboard

// MARK: - 2. Model Matching Tests

@Suite("ModelMatcher")
struct ModelMatcherTests {

    // 2.1
    @Test("Same model from different sources merges into one with multiple providers")
    func testSameModelMerges() {
        let orModels = [
            AIModel(
                id: "anthropic/claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25)],
                contextWindow: 200_000,
                maxOutput: 64_000,
                speed: nil
            )
        ]

        let llmModels = [
            AIModel(
                id: "claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0)],
                contextWindow: 200_000,
                maxOutput: 64_000,
                speed: nil
            )
        ]

        let merged = ModelMatcher.merge(openRouterModels: orModels, liteLLMModels: llmModels)

        // Should be 1 model with 2 providers
        #expect(merged.count == 1)
        #expect(merged[0].providers.count == 2)

        let providers = Set(merged[0].providers.map(\.provider))
        #expect(providers.contains(.openRouter))
        #expect(providers.contains(.anthropic))
    }

    // 2.4
    @Test("No duplicate providers after merge")
    func testNoProviderDuplicates() {
        let orModels = [
            AIModel(
                id: "anthropic/claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25)],
                contextWindow: 200_000,
                maxOutput: nil,
                speed: nil
            )
        ]

        let llmModels = [
            AIModel(
                id: "claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .openRouter, inputPer1M: 3.0, outputPer1M: 15.0)],
                contextWindow: 200_000,
                maxOutput: nil,
                speed: nil
            )
        ]

        let merged = ModelMatcher.merge(openRouterModels: orModels, liteLLMModels: llmModels)

        // Should still be 1 provider (OpenRouter) — no duplicates
        #expect(merged.count == 1)
        #expect(merged[0].providers.count == 1)
        #expect(merged[0].providers[0].provider == .openRouter)
    }

    @Test("Different models stay separate")
    func testDifferentModelsStaySeparate() {
        let orModels = [
            AIModel(
                id: "anthropic/claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .openRouter, inputPer1M: 3.0, outputPer1M: 15.0)],
                contextWindow: 200_000,
                maxOutput: nil,
                speed: nil
            )
        ]

        let llmModels = [
            AIModel(
                id: "gpt-4o",
                name: "GPT 4o",
                family: "GPT",
                providers: [ProviderPrice(provider: .openai, inputPer1M: 2.5, outputPer1M: 10.0)],
                contextWindow: 128_000,
                maxOutput: nil,
                speed: nil
            )
        ]

        let merged = ModelMatcher.merge(openRouterModels: orModels, liteLLMModels: llmModels)
        #expect(merged.count == 2)
    }

    @Test("Merge uses better metadata when available")
    func testMergeUsesBetterMetadata() {
        let orModels = [
            AIModel(
                id: "anthropic/claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25)],
                contextWindow: 0, // OpenRouter might have 0
                maxOutput: nil,
                speed: nil
            )
        ]

        let llmModels = [
            AIModel(
                id: "claude-sonnet-4",
                name: "Claude Sonnet 4",
                family: "Claude",
                providers: [ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0)],
                contextWindow: 200_000, // LiteLLM has the real value
                maxOutput: 64_000,
                speed: nil
            )
        ]

        let merged = ModelMatcher.merge(openRouterModels: orModels, liteLLMModels: llmModels)
        #expect(merged[0].contextWindow == 200_000)
    }
}
