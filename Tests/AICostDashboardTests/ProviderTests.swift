import Testing
@testable import AICostDashboard

// MARK: - Provider Tests

@Suite("Provider")
struct ProviderTests {

    @Test("All providers have display names")
    func testDisplayNames() {
        for provider in Provider.allCases {
            #expect(!provider.displayName.isEmpty)
            #expect(!provider.shortName.isEmpty)
        }
    }

    @Test("Aggregators are correctly identified")
    func testAggregators() {
        #expect(Provider.openRouter.isAggregator == true)
        #expect(Provider.bedrock.isAggregator == true)
        #expect(Provider.azure.isAggregator == true)
        #expect(Provider.vertex.isAggregator == true)

        #expect(Provider.anthropic.isAggregator == false)
        #expect(Provider.openai.isAggregator == false)
        #expect(Provider.google.isAggregator == false)
    }

    @Test("Provider count is 7")
    func testProviderCount() {
        #expect(Provider.allCases.count == 7)
    }
}
