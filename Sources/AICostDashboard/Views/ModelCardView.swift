import SwiftUI

public struct ModelCardView: View {
    public let model: AIModel
    public let isSelected: Bool

    public init(model: AIModel, isSelected: Bool) {
        self.model = model
        self.isSelected = isSelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            // Header
            HStack(spacing: Theme.spacingS) {
                Circle()
                    .fill(familyColor)
                    .frame(width: 8, height: 8)
                Text(model.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Spacer()
            }

            Text(model.family)
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)

            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1)

            // Prices
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("INPUT")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                    Text(PriceFormatter.format(model.bestInputPrice ?? 0))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("OUTPUT")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.textTertiary)
                    Text(PriceFormatter.format(model.bestOutputPrice ?? 0))
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            // Specs
            HStack(spacing: Theme.spacingM) {
                if model.contextWindow > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 9))
                        Text(PriceFormatter.formatContext(model.contextWindow))
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Theme.textTertiary)
                }

                Spacer()

                if let speed = model.speed {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt")
                            .font(.system(size: 9))
                        Text(PriceFormatter.formatSpeed(speed))
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Theme.textTertiary)
                }
            }

            // Savings badge
            if model.savingsPercent > 0, let provider = model.savingsProvider {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 8, weight: .bold))
                    Text("\(Int(model.savingsPercent))% on \(provider.shortName)")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Theme.green)
                .padding(.horizontal, Theme.spacingS)
                .padding(.vertical, Theme.spacingXS)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusS)
                        .fill(Theme.green.opacity(0.1))
                )
            }

            // Provider count
            Text("\(model.providerCount) provider\(model.providerCount == 1 ? "" : "s")")
                .font(.system(size: 10))
                .foregroundStyle(Theme.textTertiary)
        }
        .raycastCard(isSelected: isSelected)
    }

    private var familyColor: Color {
        switch model.family {
        case "Claude": Theme.providerColor(.anthropic)
        case "GPT": Theme.providerColor(.openai)
        case "Gemini": Theme.providerColor(.google)
        default: Theme.textTertiary
        }
    }
}
