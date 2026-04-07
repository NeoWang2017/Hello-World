import SwiftUI
import SwiftData

@main
struct FamilyOKRApp: App {
    @State private var store = OKRStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
        .modelContainer(for: [
            FamilyMember.self,
            Objective.self,
            KeyResult.self,
            ProgressEntry.self
        ])
        #if os(macOS)
        .defaultSize(width: 1100, height: 750)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        #endif
    }
}
