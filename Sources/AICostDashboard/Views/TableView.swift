import SwiftUI

public struct ModelTableView: View {
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
            LazyVStack(spacing: 0) {
                // Header row
                headerRow
                    .padding(.horizontal, Theme.spacingL)

                // Bordered table container (Perplexity stats-grid style)
                VStack(spacing: 0) {
                    ForEach(Array(models.enumerated()), id: \.element.id) { index, model in
                        VStack(spacing: 0) {
                            modelRow(model)

                            if expandedIds.contains(model.id) {
                                ProviderDetailView(model: model)
                                    .padding(.horizontal, Theme.spacingXL + 20)
                                    .padding(.vertical, Theme.spacingM)
                                    .background(Theme.backgroundSecondary.opacity(0.4))
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Divider between rows (not after last)
                            if index < models.count - 1 || expandedIds.contains(model.id) {
                                Rectangle()
                                    .fill(Theme.border)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusM))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusM)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .padding(.horizontal, Theme.spacingL)
                .padding(.bottom, Theme.spacingL)
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 20)

            Text("MODEL")
                .frame(minWidth: 170, alignment: .leading)

            Spacer()

            Text("INPUT / 1M")
                .frame(width: 85, alignment: .trailing)

            Text("OUTPUT / 1M")
                .frame(width: 85, alignment: .trailing)

            Text("CONTEXT")
                .frame(width: 62, alignment: .trailing)

            Text("SPEED")
                .frame(width: 60, alignment: .trailing)

            Text("SAVINGS")
                .frame(width: 70, alignment: .trailing)

            Text("#")
                .frame(width: 25, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(Theme.textTertiary)
        .padding(.horizontal, Theme.spacingL)
        .padding(.vertical, Theme.spacingS)
    }

    private func modelRow(_ model: AIModel) -> some View {
        let isExpanded = expandedIds.contains(model.id)
        let isSelected = selectedModelId == model.id

        return HStack(spacing: 0) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 20)

            HStack(spacing: Theme.spacingS) {
                Circle()
                    .fill(familyColor(model.family))
                    .frame(width: 6, height: 6)

                VStack(alignment: .leading, spacing: 1) {
                    Text(model.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(1)
                    Text(model.family)
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .frame(minWidth: 170, alignment: .leading)

            Spacer()

            Text(PriceFormatter.format(model.bestInputPrice ?? 0))
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 85, alignment: .trailing)

            Text(PriceFormatter.format(model.bestOutputPrice ?? 0))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 85, alignment: .trailing)

            Text(model.contextWindow > 0 ? PriceFormatter.formatContext(model.contextWindow) : "—")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 62, alignment: .trailing)

            Text(model.speed.map { PriceFormatter.formatSpeed($0) } ?? "—")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 60, alignment: .trailing)

            savingsBadge(model)
                .frame(width: 70, alignment: .trailing)

            Text("\(model.providerCount)")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
                .frame(width: 25, alignment: .trailing)
        }
        .padding(.horizontal, Theme.spacingL)
        .padding(.vertical, Theme.spacingS + 2)
        .background(isSelected ? Theme.backgroundSelected : (isExpanded ? Theme.backgroundHover : .clear))
        .contentShape(Rectangle())
        .onHover { hovering in
            // Hover handled by background
        }
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

    private func savingsBadge(_ model: AIModel) -> some View {
        Group {
            if model.savingsPercent > 0, model.savingsProvider != nil {
                HStack(spacing: 2) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 7, weight: .bold))
                    Text("\(Int(model.savingsPercent))%")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Theme.green)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.green.opacity(0.12))
                )
            } else {
                Text("—")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary.opacity(0.4))
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
            Text("Try adjusting your search or filters")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Theme.backgroundPrimary)
    }
}
