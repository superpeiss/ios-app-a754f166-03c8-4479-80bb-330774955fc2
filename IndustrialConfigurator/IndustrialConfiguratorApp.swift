import SwiftUI

@main
struct IndustrialConfiguratorApp: App {
    @StateObject private var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
        }
    }
}
