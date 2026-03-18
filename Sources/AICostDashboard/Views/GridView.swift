import SwiftUI

public struct ModelGridView: View {
    public let models: [AIModel]
    @Binding public var selectedModelId: String?

    private let columns = [
        GridItem(.adaptive(minimum: 210, maximum: 270), spacing: Theme.spacingM)
    ]

    public init(models: [AIModel], selectedModelId: Binding<String?>) {
        self.models = models
        self._selectedModelId = selectedModelId
    }

    public var body: some View {
        if models.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.spacingM) {
                    ForEach(models) { model in
                        ModelCardView(model: model, isSelected: selectedModelId == model.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    selectedModelId = selectedModelId == model.id ? nil : model.id
                                }
                            }
                    }
                }
                .padding(Theme.spacingL)
            }
            .background(Theme.backgroundPrimary)
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
