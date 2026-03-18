import Foundation

public struct ProviderPrice: Identifiable, Sendable, Codable {
    public let id: String
    public let provider: Provider
    public let inputPer1M: Double
    public let outputPer1M: Double

    public init(provider: Provider, inputPer1M: Double, outputPer1M: Double) {
        self.id = "\(provider.rawValue)"
        self.provider = provider
        self.inputPer1M = inputPer1M
        self.outputPer1M = outputPer1M
    }

    public var totalPer1M: Double { inputPer1M + outputPer1M }
}
