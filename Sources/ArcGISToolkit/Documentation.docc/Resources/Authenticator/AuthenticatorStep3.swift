import ArcGIS
import ArcGISToolkit
import SwiftUI

@main
struct AuthenticationApp: App {
    @StateObject private var authenticator = Authenticator()
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            HomeView()
                .authenticator(authenticator)
                .task {
                    // If the app requires the use of OAuth or Identity-Aware Proxy (IAP),
                    // then provide the necessary configurations.
                    authenticator.oAuthUserConfigurations.append(
                        OAuthUserConfiguration(
                            portalURL: URL(string: "Your client portal URL goes here")!,
                            clientID: "Your client ID goes here",
                            redirectURL: URL(string: "Your redirect URL goes here")!
                        )
                    )
                    try? await authenticator.iapConfigurations.append(
                        IAPConfiguration.configuration(from: URL(filePath: "Your IAP configuration JSON file path goes here")!)
                    )
                    ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
                    try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
                }
        }
    }
}
