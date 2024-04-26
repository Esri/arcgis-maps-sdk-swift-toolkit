import SwiftUI
import ArcGISToolkit
import ArcGIS

@main
struct AuthenticationApp: App {
    @StateObject private var authenticator = Authenticator()
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            HomeView()
                .authenticator(authenticator)
                .task {
                    ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
                    try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
                }
        }
    }
}
