import Testing
@testable import AICostDashboard

// MARK: - 4. Model Computed Properties

@Suite("AIModel Computed Properties")
struct AIModelTests {

    // Helper to create test models
    static func makeModel(
        providers: [ProviderPrice],
        contextWindow: Int = 200_000,
        speed: Double? = 78.0
    ) -> AIModel {
        AIModel(
            id: "test-model",
            name: "Test Model",
            family: "Test",
            providers: providers,
            contextWindow: contextWindow,
            maxOutput: 4096,
            speed: speed
        )
    }

    // 4.1
    @Test("Cheapest provider is the one with lowest output price")
    func testCheapestProviderIsCorrect() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25),
            ProviderPrice(provider: .vertex, inputPer1M: 3.15, outputPer1M: 15.75),
        ])

        #expect(model.cheapestProvider?.provider == .openRouter)
        #expect(model.cheapestProvider?.outputPer1M == 14.25)
    }

    // 4.2
    @Test("Savings percent is calculated correctly")
    func testSavingsPercentCalculation() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 20.0),
            ProviderPrice(provider: .openRouter, inputPer1M: 2.5, outputPer1M: 10.0),
        ])

        // (20 - 10) / 20 * 100 = 50%
        #expect(model.savingsPercent == 50.0)
        #expect(model.savingsProvider == .openRouter)
    }

    // 4.3
    @Test("Savings is zero when all providers have same price")
    func testSavingsIsZeroWhenAllSamePrice() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .bedrock, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .azure, inputPer1M: 3.0, outputPer1M: 15.0),
        ])

        #expect(model.savingsPercent == 0)
        #expect(model.savingsProvider == nil)
    }

    // 4.4
    @Test("Single provider has zero savings")
    func testSingleProviderHasZeroSavings() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
        ])

        #expect(model.savingsPercent == 0)
        #expect(model.savingsProvider == nil)
    }

    @Test("Best input and output prices")
    func testBestPrices() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .openRouter, inputPer1M: 2.5, outputPer1M: 14.0),
            ProviderPrice(provider: .vertex, inputPer1M: 4.0, outputPer1M: 13.0),
        ])

        #expect(model.bestInputPrice == 2.5)
        #expect(model.bestOutputPrice == 13.0)
    }

    @Test("Provider count is correct")
    func testProviderCount() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25),
        ])

        #expect(model.providerCount == 2)
    }

    @Test("Most expensive provider is correct")
    func testMostExpensiveProvider() {
        let model = AIModelTests.makeModel(providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .vertex, inputPer1M: 3.15, outputPer1M: 15.75),
        ])

        #expect(model.mostExpensiveProvider?.provider == .vertex)
    }
}
