// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGISToolkit
import ArcGIS

@main
struct AuthenticationApp: App {
    @ObservedObject var authenticator: Authenticator
    @State var isSettingUp = true
    
    init() {
        // Create an authenticator.
        authenticator = Authenticator(
            // If you want to use OAuth, uncomment this code:
            //oAuthUserConfigurations: [.arcgisDotCom]
        )
        // Set the ArcGIS and Network challenge handlers to be the authenticator we just created.
        ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = authenticator
        ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = authenticator
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            Group {
                if isSettingUp {
                    ProgressView()
                } else {
                    HomeView()
                }
            }
            // Using this view modifier will cause a prompt when the authenticator is asked
            // to handle an authentication challenge.
            // This will handle many different types of authentication, for example:
            // - ArcGIS authentication (token and OAuth)
            // - Integrated Windows Authentication (IWA)
            // - Client Certificate (PKI)
            .authenticator(authenticator)
            .environmentObject(authenticator)
            .task {
                isSettingUp = true
                // Here we make the authenticator persistent, which means that it will synchronize
                // with they keychain for storing credentials.
                // It also means that a user can sign in without having to be prompted for
                // credentials. Once credentials are cleared from the stores ("sign-out"),
                // then the user will need to be prompted once again.
                try? await authenticator.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
                isSettingUp = false
            }
        }
    }
}

// If you want to use OAuth, you can uncomment this code:
//private extension OAuthUserConfiguration {
//    static let arcgisDotCom = OAuthUserConfiguration(
//        portalURL: .portal,
//        clientID: "<#Your client ID goes here#>",
//        // Note: You must have the same redirect URL used here
//        // registered with your client ID.
//        // The scheme of the redirect URL is also specified in the Info.plist file.
//        redirectURL: URL(string: "authexample://auth")!
//    )
//}

extension URL {
    // If you want to use your own portal, provide your own URL here:
    static let portal = URL(string: "https://www.arcgis.com")!
}
