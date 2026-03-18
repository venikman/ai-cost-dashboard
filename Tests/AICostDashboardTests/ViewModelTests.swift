import Testing
@testable import AICostDashboard

// MARK: - 3. ViewModel Logic Tests

@Suite("DashboardViewModel")
struct ViewModelTests {

    // Test data
    static let testModels: [AIModel] = [
        AIModel(
            id: "claude-sonnet-4",
            name: "Claude Sonnet 4",
            family: "Claude",
            providers: [
                ProviderPrice(provider: .anthropic, inputPer1M: 3.0, outputPer1M: 15.0),
                ProviderPrice(provider: .openRouter, inputPer1M: 2.85, outputPer1M: 14.25),
            ],
            contextWindow: 200_000,
            maxOutput: 64_000,
            speed: 78.0
        ),
        AIModel(
            id: "gpt-4o",
            name: "GPT 4o",
            family: "GPT",
            providers: [
                ProviderPrice(provider: .openai, inputPer1M: 2.5, outputPer1M: 10.0),
            ],
            contextWindow: 128_000,
            maxOutput: 16_384,
            speed: 92.0
        ),
        AIModel(
            id: "gemini-2.0-flash",
            name: "Gemini 2.0 Flash",
            family: "Gemini",
            providers: [
                ProviderPrice(provider: .google, inputPer1M: 0.075, outputPer1M: 0.30),
                ProviderPrice(provider: .vertex, inputPer1M: 0.075, outputPer1M: 0.30),
            ],
            contextWindow: 1_000_000,
            maxOutput: 8_192,
            speed: 200.0
        ),
        AIModel(
            id: "claude-opus-4",
            name: "Claude Opus 4",
            family: "Claude",
            providers: [
                ProviderPrice(provider: .anthropic, inputPer1M: 15.0, outputPer1M: 75.0),
            ],
            contextWindow: 200_000,
            maxOutput: 32_000,
            speed: 42.0
        ),
    ]

    // 3.1
    @Test("Search filters to matching models")
    @MainActor
    func testSearchFiltersModels() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.searchText = "claude"

        let filtered = vm.filteredModels
        #expect(filtered.count == 2)
        #expect(filtered.allSatisfy { $0.family == "Claude" })
    }

    // 3.2
    @Test("Provider filter shows only models with that provider")
    @MainActor
    func testProviderFilterWorks() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.filterProvider = .anthropic

        let filtered = vm.filteredModels
        #expect(filtered.allSatisfy { model in
            model.providers.contains { $0.provider == .anthropic }
        })
        // Claude Sonnet 4 + Claude Opus 4
        #expect(filtered.count == 2)
    }

    // 3.3
    @Test("Sort by price ascending puts cheapest first")
    @MainActor
    func testSortByPriceAscending() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.sortOrder = .priceAsc

        let filtered = vm.filteredModels
        #expect(filtered.first?.name == "Gemini 2.0 Flash")
        #expect(filtered.last?.name == "Claude Opus 4")
    }

    // 3.4
    @Test("Sort by price descending puts most expensive first")
    @MainActor
    func testSortByPriceDescending() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.sortOrder = .priceDesc

        let filtered = vm.filteredModels
        #expect(filtered.first?.name == "Claude Opus 4")
        #expect(filtered.last?.name == "Gemini 2.0 Flash")
    }

    // 3.5
    @Test("Sort by context window puts largest first")
    @MainActor
    func testSortByContextWindow() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.sortOrder = .context

        let filtered = vm.filteredModels
        #expect(filtered.first?.name == "Gemini 2.0 Flash") // 1M
        #expect(filtered.first?.contextWindow == 1_000_000)
    }

    // 3.6
    @Test("Sort by savings puts highest savings first")
    @MainActor
    func testSortBySavings() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.sortOrder = .savings

        let filtered = vm.filteredModels
        // Claude Sonnet 4 has savings (OR vs Anthropic), others may have 0
        #expect(filtered.first?.savingsPercent ?? 0 >= filtered.last?.savingsPercent ?? 0)
        #expect(filtered.first?.name == "Claude Sonnet 4")
    }

    @Test("Search is case insensitive")
    @MainActor
    func testSearchCaseInsensitive() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.searchText = "GEMINI"

        let filtered = vm.filteredModels
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Gemini 2.0 Flash")
    }

    @Test("Empty search returns all models")
    @MainActor
    func testEmptySearchReturnsAll() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.searchText = ""

        #expect(vm.filteredModels.count == ViewModelTests.testModels.count)
    }

    @Test("Selected model returns correct model")
    @MainActor
    func testSelectedModel() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.selectedModelId = "gpt-4o"

        #expect(vm.selectedModel?.name == "GPT 4o")
    }

    @Test("Selected model is nil when no selection")
    @MainActor
    func testSelectedModelNil() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.selectedModelId = nil

        #expect(vm.selectedModel == nil)
    }

    @Test("Search and provider filter combine")
    @MainActor
    func testCombinedFilters() {
        let vm = DashboardViewModel()
        vm.allModels = ViewModelTests.testModels
        vm.searchText = "claude"
        vm.filterProvider = .openRouter

        let filtered = vm.filteredModels
        // Only Claude Sonnet 4 has both "claude" in name AND OpenRouter provider
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Claude Sonnet 4")
    }
}
