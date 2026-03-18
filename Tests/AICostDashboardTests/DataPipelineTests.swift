import Testing
@testable import AICostDashboard

// MARK: - 1. Data Pipeline (E2E) Tests
// These tests hit real APIs — they verify the full pipeline works.

@Suite("Data Pipeline E2E")
struct DataPipelineTests {

    // 1.1
    @Test("OpenRouter API returns non-empty model list")
    func testOpenRouterFetchReturnsModels() async throws {
        let api = OpenRouterAPI()
        let models = try await api.fetchModels()

        #expect(!models.isEmpty)
        #expect(models.count > 10) // Should return hundreds
    }

    // 1.2
    @Test("OpenRouter parses required fields correctly")
    func testOpenRouterParsesCorrectFields() async throws {
        let api = OpenRouterAPI()
        let models = try await api.fetchModels()

        // Find a well-known model
        let gpt4o = models.first { $0.id.contains("gpt-4o") && !$0.id.contains("mini") }

        #expect(gpt4o != nil)
        if let model = gpt4o {
            #expect(!model.name.isEmpty)
            #expect(model.contextWindow > 0)
            #expect(model.providers.count == 1) // OpenRouter = 1 provider
            #expect(model.providers[0].provider == .openRouter)
            #expect(model.providers[0].inputPer1M > 0)
            #expect(model.providers[0].outputPer1M > 0)
        }
    }

    // 1.3
    @Test("LiteLLM fetch returns non-empty model list")
    func testLiteLLMFetchReturnsModels() async throws {
        let source = LiteLLMDataSource()
        let models = try await source.fetchModels()

        #expect(!models.isEmpty)
        #expect(models.count > 50) // Should have many models
    }

    // 1.4
    @Test("LiteLLM maps litellm_provider to correct Provider enum")
    func testLiteLLMParsesProviderCorrectly() async throws {
        let source = LiteLLMDataSource()
        let models = try await source.fetchModels()

        let providers = Set(models.map { $0.providers.first!.provider })

        // Should include at least some of our tracked providers
        #expect(providers.contains(.anthropic) || providers.contains(.bedrock))
        #expect(providers.contains(.openai) || providers.contains(.azure))
    }

    // 1.5
    @Test("Full pipeline merges models from both sources")
    func testFullPipelineMergesModels() async throws {
        let api = OpenRouterAPI()
        let litellm = LiteLLMDataSource()

        async let orModels = api.fetchModels()
        async let llmModels = litellm.fetchModels()

        let merged = try await ModelMatcher.merge(
            openRouterModels: orModels,
            liteLLMModels: llmModels
        )

        #expect(!merged.isEmpty)

        // Some models should have multiple providers after merge
        let multiProvider = merged.filter { $0.providers.count > 1 }
        #expect(!multiProvider.isEmpty)
    }

    // 1.6
    @Test("Featured filter reduces model count significantly")
    func testFeaturedFilterReducesModelCount() async throws {
        let api = OpenRouterAPI()
        let litellm = LiteLLMDataSource()

        async let orModels = api.fetchModels()
        async let llmModels = litellm.fetchModels()

        let merged = try await ModelMatcher.merge(
            openRouterModels: orModels,
            liteLLMModels: llmModels
        )

        // Featured filter should give us significantly fewer models
        // (The filter is applied inside merge now)
        #expect(merged.count < 200) // Was 667 unfiltered
        #expect(merged.count > 5)   // But should have at least a few
    }
}
