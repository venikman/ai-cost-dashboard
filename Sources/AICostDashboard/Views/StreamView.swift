import SwiftUI

public struct ModelStreamView: View {
    public let models: [AIModel]
    @Binding public var selectedModelId: String?

    @State private var expandedIds: Set<String> = []

    public init(models: [AIModel], selectedModelId: Binding<String?>) {
        self.models = models
        self._selectedModelId = selectedModelId
    }

    public var body: some View {
        if models.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(models) { model in
                        VStack(spacing: 0) {
                            streamRow(model)

                            if expandedIds.contains(model.id) {
                                ProviderDetailView(model: model)
                                    .padding(.horizontal, Theme.spacingXL + 24)
                                    .padding(.vertical, Theme.spacingS)
                                    .background(Theme.backgroundSecondary.opacity(0.4))
                                    .transition(.opacity)
                            }

                            Rectangle()
                                .fill(Theme.divider)
                                .frame(height: 1)
                                .padding(.horizontal, Theme.spacingXL)
                        }
                    }
                }
                .padding(.vertical, Theme.spacingS)
            }
            .background(Theme.backgroundPrimary)
        }
    }

    private func streamRow(_ model: AIModel) -> some View {
        let isSelected = selectedModelId == model.id

        return HStack(alignment: .center, spacing: Theme.spacingL) {
            // Left: name and metadata
            HStack(spacing: Theme.spacingS) {
                Circle()
                    .fill(familyColor(model.family))
                    .frame(width: 7, height: 7)

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)

                    HStack(spacing: Theme.spacingS) {
                        Text(model.family)
                            .foregroundStyle(Theme.textTertiary)

                        if model.contextWindow > 0 {
                            Text("·").foregroundStyle(Theme.textTertiary.opacity(0.5))
                            Text(PriceFormatter.formatContext(model.contextWindow))
                                .foregroundStyle(Theme.textTertiary)
                        }

                        if let speed = model.speed {
                            Text("·").foregroundStyle(Theme.textTertiary.opacity(0.5))
                            Text(PriceFormatter.formatSpeed(speed))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    .font(.system(size: 11))
                }
            }

            Spacer()

            // Right: price and savings
            VStack(alignment: .trailing, spacing: 3) {
                Text(PriceFormatter.formatPair(
                    input: model.bestInputPrice ?? 0,
                    output: model.bestOutputPrice ?? 0
                ))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)

                Text("per 1M tokens")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textTertiary)
            }

            if model.savingsPercent > 0, let provider = model.savingsProvider {
                Text("\(PriceFormatter.formatSavings(model.savingsPercent)) \(provider.shortName)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.green)
                    .padding(.horizontal, Theme.spacingS)
                    .padding(.vertical, Theme.spacingXS)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusS)
                            .fill(Theme.green.opacity(0.1))
                    )
            }
        }
        .raycastRow(isSelected: isSelected)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                if expandedIds.contains(model.id) {
                    expandedIds.remove(model.id)
                } else {
                    expandedIds.insert(model.id)
                }
                selectedModelId = model.id
            }
        }
    }

    private func familyColor(_ family: String) -> Color {
        switch family {
        case "Claude": Theme.providerColor(.anthropic)
        case "GPT": Theme.providerColor(.openai)
        case "Gemini": Theme.providerColor(.google)
        case "DeepSeek": Color(red: 0.3, green: 0.6, blue: 1.0)
        case "Mistral": Color(red: 1.0, green: 0.5, blue: 0.2)
        default: Theme.textTertiary
        }
    }

    private var emptyState: some View {
        VStack(spacing: Theme.spacingM) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(Theme.textTertiary)
            Text("No models found")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundPrimary)
    }
}
