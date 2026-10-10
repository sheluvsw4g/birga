import SwiftUI
import TonRateCore

@main
struct TonRateTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                #if os(macOS)
                .frame(minWidth: 420, minHeight: 620)
                #endif
        }
    }
}
