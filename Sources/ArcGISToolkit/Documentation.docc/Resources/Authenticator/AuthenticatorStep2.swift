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
}
