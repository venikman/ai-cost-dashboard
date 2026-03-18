import Foundation

public struct AIModel: Identifiable, Sendable, Codable {
    public let id: String
    public let name: String
    public let family: String
    public var providers: [ProviderPrice]
    public let contextWindow: Int
    public let maxOutput: Int?
    public let speed: Double?

    public init(id: String, name: String, family: String, providers: [ProviderPrice], contextWindow: Int, maxOutput: Int?, speed: Double?) {
        self.id = id
        self.name = name
        self.family = family
        self.providers = providers
        self.contextWindow = contextWindow
        self.maxOutput = maxOutput
        self.speed = speed
    }

    public var cheapestProvider: ProviderPrice? {
        providers.min(by: { $0.outputPer1M < $1.outputPer1M })
    }

    public var mostExpensiveProvider: ProviderPrice? {
        providers.max(by: { $0.outputPer1M < $1.outputPer1M })
    }

    public var bestInputPrice: Double? {
        providers.map(\.inputPer1M).min()
    }

    public var bestOutputPrice: Double? {
        providers.map(\.outputPer1M).min()
    }

    public var savingsPercent: Double {
        guard let cheapest = cheapestProvider?.outputPer1M,
              let expensive = mostExpensiveProvider?.outputPer1M,
              expensive > 0, cheapest < expensive else { return 0 }
        return ((expensive - cheapest) / expensive) * 100
    }

    public var savingsProvider: Provider? {
        guard savingsPercent > 0 else { return nil }
        return cheapestProvider?.provider
    }

    public var providerCount: Int { providers.count }
}
