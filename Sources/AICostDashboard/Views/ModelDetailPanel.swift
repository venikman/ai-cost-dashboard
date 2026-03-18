import SwiftUI

/// Perplexity Finance-style right sidebar showing model details.
/// Key-value pairs with clean rows + provider price range indicator.
public struct ModelDetailPanel: View {
    public let model: AIModel

    public init(model: AIModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(model.family)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(Theme.spacingL)

                sectionDivider

                // Price highlight
                VStack(alignment: .leading, spacing: 6) {
                    if let best = model.bestOutputPrice {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(PriceFormatter.format(best))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(Theme.textPrimary)

                            Text("/ 1M output")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textTertiary)
                        }

                        if model.savingsPercent > 0, let provider = model.savingsProvider {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.right")
                                    .font(.system(size: 10, weight: .bold))
                                Text("\(Int(model.savingsPercent))% cheaper on \(provider.shortName)")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(Theme.green)
                        }
                    }
                }
                .padding(Theme.spacingL)

                sectionDivider

                // Key-value pairs (Perplexity style)
                VStack(spacing: 0) {
                    kvRow("Best Input Price", PriceFormatter.format(model.bestInputPrice ?? 0))
                    kvRow("Best Output Price", PriceFormatter.format(model.bestOutputPrice ?? 0))
                    kvRow("Context Window", model.contextWindow > 0 ? PriceFormatter.formatContext(model.contextWindow) : "—")
                    if let maxOut = model.maxOutput {
                        kvRow("Max Output", PriceFormatter.formatContext(maxOut))
                    }
                    if let speed = model.speed {
                        kvRow("Speed", PriceFormatter.formatSpeed(speed))
                    }
                    kvRow("Providers", "\(model.providerCount)")
                }

                sectionDivider

                // Provider price comparison (like Analyst Consensus)
                VStack(alignment: .leading, spacing: Theme.spacingM) {
                    HStack {
                        Text("Provider Pricing")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text("\(model.providerCount) providers")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                    }

                    // Distribution bar (Analyst Consensus style)
                    if model.providers.count > 1 {
                        priceDistributionBar
                    }

                    // Provider list
                    ProviderDetailView(model: model)

                    // Price range indicator (like price target range)
                    if model.providers.count > 1 {
                        priceRangeIndicator
                    }
                }
                .padding(Theme.spacingL)

                Spacer()
            }
        }
        .frame(width: 360)
        .background(Theme.backgroundSecondary)
        .overlay(
            Rectangle()
                .fill(Theme.border)
                .frame(width: 1),
            alignment: .leading
        )
    }

    // MARK: - Key-Value Row (Perplexity style)

    private func kvRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.horizontal, Theme.spacingL)
        .padding(.vertical, Theme.spacingS + 1)
        .overlay(
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Price Distribution Bar (like Analyst Consensus)

    private var priceDistributionBar: some View {
        let sorted = model.providers.sorted(by: { $0.outputPer1M < $1.outputPer1M })
        let minPrice = sorted.first?.outputPer1M ?? 0
        let maxPrice = sorted.last?.outputPer1M ?? 1

        return VStack(spacing: Theme.spacingS) {
            // Bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    ForEach(sorted) { provider in
                        let width = maxPrice > minPrice
                            ? max(20, geo.size.width / CGFloat(sorted.count))
                            : geo.size.width / CGFloat(sorted.count)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.providerColor(provider.provider))
                            .frame(width: width - 2)
                            .overlay(
                                Text(provider.provider.shortName)
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .lineLimit(1)
                            )
                    }
                }
            }
            .frame(height: 22)
            .clipShape(RoundedRectangle(cornerRadius: 4))

            // Legend
            HStack {
                HStack(spacing: 3) {
                    Circle().fill(Theme.green).frame(width: 5, height: 5)
                    Text("Cheapest")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.textTertiary)
                }
                Spacer()
                HStack(spacing: 3) {
                    Circle().fill(Theme.red).frame(width: 5, height: 5)
                    Text("Most Expensive")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
    }

    // MARK: - Price Range Indicator (like Price Target Range)

    private var priceRangeIndicator: some View {
        let prices = model.providers.map(\.outputPer1M).sorted()
        let minP = prices.first ?? 0
        let maxP = prices.last ?? 1
        let bestP = model.bestOutputPrice ?? minP

        return VStack(spacing: Theme.spacingS) {
            Text("OUTPUT PRICE RANGE")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(Theme.textTertiary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.backgroundTertiary)
                        .frame(height: 4)

                    // Filled portion
                    if maxP > minP {
                        let fraction = (bestP - minP) / (maxP - minP)
                        let xPos = geo.size.width * CGFloat(fraction)

                        // Current position dot
                        Circle()
                            .fill(Theme.green)
                            .frame(width: 10, height: 10)
                            .offset(x: xPos - 5)
                    }
                }
            }
            .frame(height: 10)

            // Labels
            HStack {
                VStack(alignment: .leading) {
                    Text(PriceFormatter.format(minP))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.green)
                    Text("Low")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                VStack {
                    Text(PriceFormatter.format(bestP))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Best")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(PriceFormatter.format(maxP))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.red)
                    Text("High")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
        }
        .padding(Theme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusM)
                .fill(Theme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .stroke(Theme.border, lineWidth: 1)
                )
        )
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Theme.border)
            .frame(height: 1)
    }
}
