import Foundation
import Testing
@testable import AICostDashboard

// MARK: - Detail Panel Data Tests
// Verifies the model data that feeds the right sidebar is complete and correct.

@Suite("Detail Panel Data")
struct DetailPanelTests {

    static let testModel = AIModel(
        id: "claude-sonnet-4",
        name: "Claude Sonnet 4",
        family: "Claude",
        providers: [
            ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
            ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25),
            ProviderPrice(provider: .bedrock, inputPer1M: 3.0, outputPer1M: 15.0),
        ],
        contextWindow: 200_000,
        maxOutput: 64_000,
        speed: 78.0
    )

    @Test("All detail panel fields are non-nil and displayable")
    func testDetailFieldsExist() {
        let model = DetailPanelTests.testModel

        // Name and family should be human-readable, not raw IDs
        #expect(!model.name.isEmpty)
        #expect(!model.name.contains("anthropic."))
        #expect(!model.name.contains("apac."))
        #expect(!model.name.contains("au."))
        #expect(!model.family.isEmpty)

        // Prices must exist
        #expect(model.bestInputPrice != nil)
        #expect(model.bestOutputPrice != nil)
        #expect(model.bestInputPrice! > 0)
        #expect(model.bestOutputPrice! > 0)

        // Context and output must be set
        #expect(model.contextWindow > 0)
        #expect(model.maxOutput != nil)
        #expect(model.maxOutput! > 0)

        // Providers must be populated
        #expect(model.providerCount >= 1)

        // Speed should be available
        #expect(model.speed != nil)
    }

    @Test("Detail panel price formatting fits within reasonable width")
    func testPriceFormattingLength() {
        let model = DetailPanelTests.testModel

        // All formatted values should be short enough for the sidebar
        let inputStr = PriceFormatter.format(model.bestInputPrice!)
        let outputStr = PriceFormatter.format(model.bestOutputPrice!)
        let contextStr = PriceFormatter.formatContext(model.contextWindow)

        #expect(inputStr.count <= 12)  // e.g. "$3.00" or "$0.0750"
        #expect(outputStr.count <= 12)
        #expect(contextStr.count <= 6)  // e.g. "200K" or "1.5M"
    }

    @Test("Detail panel shows savings when applicable")
    func testSavingsInDetailPanel() {
        let model = DetailPanelTests.testModel

        // This model has different prices across providers
        #expect(model.savingsPercent > 0)
        #expect(model.savingsProvider != nil)
        #expect(model.cheapestProvider?.provider == .openRouter)
    }

    @Test("Detail panel provider list is sorted cheapest first")
    func testProvidersSortedByCost() {
        let model = DetailPanelTests.testModel
        let sorted = model.providers.sorted(by: { $0.outputPer1M < $1.outputPer1M })

        #expect(sorted.first?.provider == .openRouter) // $14.25
        #expect(sorted.last?.outputPer1M == 15.0)      // Anthropic or Bedrock
    }

    @Test("Selected model in ViewModel populates detail panel")
    @MainActor
    func testSelectedModelForPanel() {
        let vm = DashboardViewModel()
        vm.allModels = [DetailPanelTests.testModel]
        vm.selectedModelId = "claude-sonnet-4"

        let selected = vm.selectedModel
        #expect(selected != nil)
        #expect(selected?.name == "Claude Sonnet 4")
        #expect(selected?.providerCount == 3)
    }

    @Test("Deselecting model clears detail panel")
    @MainActor
    func testDeselectClearsPanel() {
        let vm = DashboardViewModel()
        vm.allModels = [DetailPanelTests.testModel]
        vm.selectedModelId = "claude-sonnet-4"
        #expect(vm.selectedModel != nil)

        vm.selectedModelId = nil
        #expect(vm.selectedModel == nil)
    }
}

// MARK: - Model Name Cleaning Tests
// Verifies that raw LiteLLM keys get cleaned into human-readable names.

@Suite("Model Name Cleaning")
struct ModelNameCleaningTests {

    @Test("LiteLLM model names don't contain raw prefixes")
    func testLiteLLMNamesAreCleaned() async throws {
        let source = LiteLLMDataSource()
        let models = try await source.fetchModels()

        let badPrefixes = ["apac.", "au.", "anthropic.", "bedrock/", "vertex_ai/", "azure/"]

        for model in models.prefix(50) {
            for prefix in badPrefixes {
                #expect(
                    !model.name.lowercased().hasPrefix(prefix),
                    "Model name '\(model.name)' still has raw prefix '\(prefix)'"
                )
            }
        }
    }

    @Test("Model names don't contain long date suffixes")
    func testNamesHaveNoDateSuffixes() async throws {
        let source = LiteLLMDataSource()
        let models = try await source.fetchModels()

        let datePattern = try NSRegularExpression(pattern: #"\d{8}$"#)

        for model in models.prefix(50) {
            let range = NSRange(model.name.startIndex..., in: model.name)
            let hasDate = datePattern.firstMatch(in: model.name, range: range) != nil
            #expect(!hasDate, "Model name '\(model.name)' still has date suffix")
        }
    }
}
