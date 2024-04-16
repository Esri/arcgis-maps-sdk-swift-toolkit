import SwiftUI
import ArcGISToolkit
import ArcGIS

@main
struct AuthenticationApp: App {
    @ObservedObject var authenticator: Authenticator
    
    init() {
        authenticator = Authenticator()
        ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            HomeView()
                .authenticator(authenticator)
                .environmentObject(authenticator)
                .task {
                    try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
                }
        }
    }
}
