import SwiftUI

/// Perplexity Finance-style stats banner at the top of the dashboard.
/// Shows key metrics in a bordered grid, like the "Prev Close / Market Cap / Open" row.
public struct SummaryBannerView: View {
    public let models: [AIModel]

    public init(models: [AIModel]) {
        self.models = models
    }

    private var totalModels: Int { models.count }

    private var cheapestModel: AIModel? {
        models.filter { ($0.bestOutputPrice ?? .infinity) > 0 }
            .min(by: { ($0.bestOutputPrice ?? .infinity) < ($1.bestOutputPrice ?? .infinity) })
    }

    private var mostExpensiveModel: AIModel? {
        models.max(by: { ($0.bestOutputPrice ?? 0) < ($1.bestOutputPrice ?? 0) })
    }

    private var bestSavings: AIModel? {
        models.max(by: { $0.savingsPercent < $1.savingsPercent })
    }

    private var totalProviders: Int {
        Set(models.flatMap { $0.providers.map(\.provider) }).count
    }

    public var body: some View {
        HStack(spacing: 0) {
            statCell(
                label: "Models",
                value: "\(totalModels)",
                detail: "\(totalProviders) providers",
                isFirst: true
            )

            statDivider

            if let cheapest = cheapestModel {
                statCell(
                    label: "Cheapest Output",
                    value: PriceFormatter.format(cheapest.bestOutputPrice ?? 0),
                    detail: cheapest.name,
                    valueColor: Theme.green
                )

                statDivider
            }

            if let expensive = mostExpensiveModel {
                statCell(
                    label: "Most Expensive",
                    value: PriceFormatter.format(expensive.bestOutputPrice ?? 0),
                    detail: expensive.name,
                    valueColor: Theme.textSecondary
                )

                statDivider
            }

            if let savings = bestSavings, savings.savingsPercent > 0 {
                statCell(
                    label: "Best Savings",
                    value: "\(Int(savings.savingsPercent))%",
                    detail: "\(savings.name) via \(savings.savingsProvider?.shortName ?? "")",
                    valueColor: Theme.green
                )

                statDivider
            }

            if let widest = widestContextModel {
                statCell(
                    label: "Largest Context",
                    value: PriceFormatter.formatContext(widest.contextWindow),
                    detail: widest.name,
                    isLast: true
                )
            }
        }
        .background(Theme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .stroke(Theme.border, lineWidth: 1)
        )
    }

    private func statCell(
        label: String,
        value: String,
        detail: String,
        valueColor: Color = Theme.textPrimary,
        isFirst: Bool = false,
        isLast: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundStyle(valueColor)

            Text(detail)
                .font(.system(size: 10))
                .foregroundStyle(Theme.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.spacingL)
        .padding(.vertical, Theme.spacingM)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(width: 1)
            .padding(.vertical, Theme.spacingS)
    }

    private var widestContextModel: AIModel? {
        models.max(by: { $0.contextWindow < $1.contextWindow })
    }
}
