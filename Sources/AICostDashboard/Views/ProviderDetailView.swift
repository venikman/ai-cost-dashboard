import SwiftUI

public struct ProviderDetailView: View {
    public let model: AIModel

    public init(model: AIModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            // Header
            HStack {
                Text("PROVIDER COMPARISON")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)

                Spacer()

                Text("Input / Output per 1M tokens")
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.textTertiary.opacity(0.6))
            }
            .padding(.bottom, Theme.spacingXS)

            ForEach(model.providers.sorted(by: { $0.outputPer1M < $1.outputPer1M })) { price in
                providerRow(price)
            }
        }
        .padding(.vertical, Theme.spacingXS)
    }

    private func providerRow(_ price: ProviderPrice) -> some View {
        let isCheapest = price.id == model.cheapestProvider?.id && model.providers.count > 1

        return HStack(spacing: Theme.spacingS) {
            // Indicator
            if isCheapest {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Theme.accent)
            } else {
                Circle()
                    .fill(Theme.providerColor(price.provider))
                    .frame(width: 6, height: 6)
            }

            // Provider name
            Text(price.provider.shortName)
                .font(.system(size: 12, weight: isCheapest ? .semibold : .regular))
                .foregroundStyle(isCheapest ? Theme.textPrimary : Theme.textSecondary)
                .frame(width: 80, alignment: .leading)

            // Prices
            Text(PriceFormatter.format(price.inputPer1M))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 65, alignment: .trailing)

            Text("/")
                .font(.system(size: 10))
                .foregroundStyle(Theme.textTertiary.opacity(0.4))

            Text(PriceFormatter.format(price.outputPer1M))
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(isCheapest ? Theme.textPrimary : Theme.textSecondary)
                .frame(width: 65, alignment: .trailing)

            Spacer()

            // Diff badge
            if let cheapest = model.cheapestProvider,
               price.outputPer1M > cheapest.outputPer1M,
               cheapest.outputPer1M > 0 {
                let diff = ((price.outputPer1M - cheapest.outputPer1M) / cheapest.outputPer1M) * 100
                Text("+\(Int(diff))%")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.red.opacity(0.8))
                    .frame(width: 45, alignment: .trailing)
            } else if isCheapest {
                Text("best")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.green)
                    .frame(width: 45, alignment: .trailing)
            } else {
                Spacer()
                    .frame(width: 45)
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, Theme.spacingS)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusS)
                .fill(isCheapest ? Theme.accent.opacity(0.06) : .clear)
        )
    }
}
