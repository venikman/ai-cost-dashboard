import SwiftUI

public struct DashboardView: View {
    @Bindable public var viewModel: DashboardViewModel

    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Main content area
            VStack(spacing: 0) {
                toolbar
                Rectangle().fill(Theme.divider).frame(height: 1)

                if viewModel.isLoading && viewModel.allModels.isEmpty {
                    loadingState
                } else if let error = viewModel.errorMessage, viewModel.allModels.isEmpty {
                    errorState(error)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Summary banner (Perplexity stats row)
                            SummaryBannerView(models: viewModel.filteredModels)
                                .padding(.horizontal, Theme.spacingL)
                                .padding(.top, Theme.spacingL)
                                .padding(.bottom, Theme.spacingM)

                            // Pill tabs + sort (Perplexity time-range style)
                            controlBar
                                .padding(.horizontal, Theme.spacingL)
                                .padding(.bottom, Theme.spacingM)

                            // Main view content
                            viewContent
                        }
                    }
                    .background(Theme.backgroundPrimary)
                }
            }

            // Right detail panel (Perplexity sidebar style)
            if let model = viewModel.selectedModel {
                ModelDetailPanel(model: model)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: viewModel.selectedModelId)
        .task {
            await viewModel.loadCachedThenFetch()
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    // MARK: - Toolbar (simplified — sidebar removed, Perplexity-clean)

    private var toolbar: some View {
        HStack(spacing: Theme.spacingM) {
            // App name
            HStack(spacing: Theme.spacingS) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accent)
                Text("AI Cost")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }

            // Search bar
            HStack(spacing: Theme.spacingS) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)

                TextField("Search models...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textPrimary)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .raycastSearchBar()
            .frame(maxWidth: 260)

            // Provider filter
            Menu {
                Button("All Providers") { viewModel.filterProvider = nil }
                Divider()
                ForEach(Provider.allCases) { provider in
                    Button {
                        viewModel.filterProvider = provider
                    } label: {
                        HStack {
                            Text(provider.displayName)
                            if viewModel.filterProvider == provider {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 10))
                    Text(viewModel.filterProvider?.shortName ?? "All Providers")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, Theme.spacingS + 2)
                .padding(.vertical, Theme.spacingXS + 2)
                .background(
                    RoundedRectangle(cornerRadius: Theme.radiusS)
                        .fill(Theme.backgroundTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusS)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // Status
            statusIndicator

            // Refresh
            Button {
                Task { await viewModel.fetchAll() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.radiusS)
                            .fill(Theme.backgroundTertiary)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.radiusS)
                                    .stroke(Theme.border, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut("r", modifiers: .command)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, Theme.spacingL)
        .padding(.vertical, Theme.spacingS + 2)
        .background(Theme.backgroundSecondary.opacity(0.6))
    }

    // MARK: - Control Bar (Perplexity pill tabs)

    private var controlBar: some View {
        HStack(spacing: Theme.spacingM) {
            // View mode pills (like Perplexity's 1D, 5D, 1M tabs)
            HStack(spacing: 2) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    pillButton(
                        label: mode.rawValue,
                        icon: mode.icon,
                        isActive: viewModel.selectedView == mode
                    ) {
                        viewModel.selectedView = mode
                    }
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusM)
                            .stroke(Theme.border, lineWidth: 1)
                    )
            )

            Rectangle().fill(Theme.divider).frame(width: 1, height: 20)

            // Sort pills
            HStack(spacing: 2) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    pillButton(
                        label: order.rawValue,
                        isActive: viewModel.sortOrder == order
                    ) {
                        viewModel.sortOrder = order
                    }
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusM)
                    .fill(Theme.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusM)
                            .stroke(Theme.border, lineWidth: 1)
                    )
            )

            Spacer()

            // Model count
            Text("\(viewModel.filteredModels.count) models")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textTertiary)
        }
    }

    private func pillButton(label: String, icon: String? = nil, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 3) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 9))
                }
                Text(label)
                    .font(.system(size: 11, weight: isActive ? .semibold : .regular))
            }
            .foregroundStyle(isActive ? Theme.textPrimary : Theme.textTertiary)
            .padding(.horizontal, Theme.spacingS + 2)
            .padding(.vertical, Theme.spacingXS + 1)
            .background(
                RoundedRectangle(cornerRadius: Theme.radiusS)
                    .fill(isActive ? Theme.backgroundSelected : .clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - View Content

    @ViewBuilder
    private var viewContent: some View {
        switch viewModel.selectedView {
        case .grid:
            ModelGridView(
                models: viewModel.filteredModels,
                selectedModelId: $viewModel.selectedModelId
            )
        case .table:
            ModelTableView(
                models: viewModel.filteredModels,
                selectedModelId: $viewModel.selectedModelId
            )
        case .stream:
            ModelStreamView(
                models: viewModel.filteredModels,
                selectedModelId: $viewModel.selectedModelId
            )
        }
    }

    // MARK: - Status

    @ViewBuilder
    private var statusIndicator: some View {
        if viewModel.isLoading {
            HStack(spacing: Theme.spacingXS) {
                ProgressView()
                    .controlSize(.small)
                    .tint(Theme.textTertiary)
                Text("Updating...")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textTertiary)
            }
        } else if let date = viewModel.lastUpdated {
            HStack(spacing: Theme.spacingXS) {
                Circle()
                    .fill(viewModel.isFromCache ? .orange.opacity(0.6) : Theme.green.opacity(0.6))
                    .frame(width: 5, height: 5)
                Text(viewModel.isFromCache ? "Cached" : date.formatted(.relative(presentation: .named)))
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
    }

    // MARK: - States

    private var loadingState: some View {
        VStack(spacing: Theme.spacingL) {
            ProgressView()
                .controlSize(.large)
                .tint(Theme.accent)
            Text("Loading AI model pricing...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Text("Fetching from OpenRouter & LiteLLM")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundPrimary)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: Theme.spacingL) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(Theme.textTertiary)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Button("Retry") {
                Task { await viewModel.fetchAll() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.backgroundPrimary)
    }
}
