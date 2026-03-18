import SwiftUI

public enum ViewMode: String, CaseIterable {
    case grid = "Grid"
    case table = "Table"
    case stream = "Stream"

    public var icon: String {
        switch self {
        case .grid: "square.grid.2x2"
        case .table: "tablecells"
        case .stream: "list.bullet"
        }
    }
}

public enum SortOrder: String, CaseIterable {
    case name = "Name"
    case priceAsc = "Price ↑"
    case priceDesc = "Price ↓"
    case context = "Context"
    case speed = "Speed"
    case savings = "Savings"
}

@Observable
@MainActor
public final class DashboardViewModel {
    public var allModels: [AIModel] = []
    public var selectedView: ViewMode = .table
    public var sortOrder: SortOrder = .name
    public var searchText = ""
    public var filterProvider: Provider? = nil
    public var selectedModelId: String? = nil
    public var isLoading = false
    public var isFromCache = false
    public var lastUpdated: Date? = nil
    public var errorMessage: String? = nil

    private let service = PricingService()
    private var refreshTask: Task<Void, Never>?

    public init() {}

    public var filteredModels: [AIModel] {
        var result = allModels

        // Search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.family.lowercased().contains(query)
            }
        }

        // Provider filter
        if let provider = filterProvider {
            result = result.filter { model in
                model.providers.contains { $0.provider == provider }
            }
        }

        // Sort
        switch sortOrder {
        case .name:
            result.sort { $0.name < $1.name }
        case .priceAsc:
            result.sort { ($0.bestOutputPrice ?? .infinity) < ($1.bestOutputPrice ?? .infinity) }
        case .priceDesc:
            result.sort { ($0.bestOutputPrice ?? 0) > ($1.bestOutputPrice ?? 0) }
        case .context:
            result.sort { $0.contextWindow > $1.contextWindow }
        case .speed:
            result.sort { ($0.speed ?? 0) > ($1.speed ?? 0) }
        case .savings:
            result.sort { $0.savingsPercent > $1.savingsPercent }
        }

        return result
    }

    public var selectedModel: AIModel? {
        guard let id = selectedModelId else { return nil }
        return allModels.first { $0.id == id }
    }

    public func fetchAll() async {
        isLoading = true
        errorMessage = nil

        let result = await service.fetchAll()
        allModels = result.models
        isFromCache = result.fromCache
        lastUpdated = Date()
        isLoading = false

        if result.models.isEmpty {
            errorMessage = "No models loaded. Check your internet connection."
        }
    }

    public func loadCachedThenFetch() async {
        // Show cached data instantly
        if let cached = await service.loadCached() {
            allModels = cached
            isFromCache = true
        }
        // Then fetch fresh data
        await fetchAll()
    }

    public func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(900)) // 15 minutes
                guard !Task.isCancelled else { break }
                await fetchAll()
            }
        }
    }

    public func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
