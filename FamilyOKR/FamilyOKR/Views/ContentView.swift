import SwiftUI
import SwiftData

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case objectives = "Objectives"
    case members = "Family"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "chart.bar.fill"
        case .objectives: return "target"
        case .members: return "person.3.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @Environment(OKRStore.self) private var store
    @State private var selectedTab: AppTab = .dashboard
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        #if os(macOS)
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            detailView
        }
        #else
        TabView(selection: $selectedTab) {
            Tab(AppTab.dashboard.rawValue, systemImage: AppTab.dashboard.icon, value: .dashboard) {
                NavigationStack {
                    DashboardView()
                }
            }
            Tab(AppTab.objectives.rawValue, systemImage: AppTab.objectives.icon, value: .objectives) {
                NavigationStack {
                    ObjectivesListView()
                }
            }
            Tab(AppTab.members.rawValue, systemImage: AppTab.members.icon, value: .members) {
                NavigationStack {
                    MembersListView()
                }
            }
            Tab(AppTab.settings.rawValue, systemImage: AppTab.settings.icon, value: .settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        #endif
    }

    #if os(macOS)
    private var sidebar: some View {
        List(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .tag(tab)
            }
        }
        .navigationTitle("Family OKR")
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView()
        case .objectives:
            ObjectivesListView()
        case .members:
            MembersListView()
        case .settings:
            SettingsView()
        }
    }
    #endif
}
