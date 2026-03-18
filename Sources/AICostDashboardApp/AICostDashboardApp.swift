import SwiftUI
import AICostDashboard

@main
struct AICostDashboardApp: App {
    @State private var viewModel = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: viewModel)
                .frame(minWidth: 900, minHeight: 550)
                .preferredColorScheme(.dark)
                .background(Theme.backgroundPrimary)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 1200, height: 750)
        .commands {
            CommandGroup(replacing: .newItem) {}
            // Standard Edit menu for ⌘C/⌘V/⌘X
            CommandGroup(replacing: .pasteboard) {
                Button("Cut") { NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil) }
                    .keyboardShortcut("x", modifiers: .command)
                Button("Copy") { NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil) }
                    .keyboardShortcut("c", modifiers: .command)
                Button("Paste") { NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil) }
                    .keyboardShortcut("v", modifiers: .command)
                Button("Select All") { NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil) }
                    .keyboardShortcut("a", modifiers: .command)
            }
            CommandMenu("View") {
                Button("Grid View") { viewModel.selectedView = .grid }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Table View") { viewModel.selectedView = .table }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Stream View") { viewModel.selectedView = .stream }
                    .keyboardShortcut("3", modifiers: .command)
                Divider()
                Button("Refresh") { Task { await viewModel.fetchAll() } }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
