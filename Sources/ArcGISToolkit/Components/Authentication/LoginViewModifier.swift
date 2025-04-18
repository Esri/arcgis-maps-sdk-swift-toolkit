// Copyright 2023 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// A view modifier that prompts a user to login with a username and password.
struct LoginViewModifier: ViewModifier {
    /// The host that initiated the challenge.
    let challengingHost: String
    /// The action to perform when the user signs in. This is a closure that
    /// takes a login credential.
    let onSignIn: (LoginCredential) -> Void
    /// The action to perform when the user cancels.
    let onCancel: () -> Void
    
    /// A Boolean value indicating whether or not the prompt to login is displayed.
    @State private var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .delayedOnAppear {
                // Present the sheet right away.
                // Setting it after initialization allows it to animate.
                // However, this needs to happen after a slight delay or
                // it doesn't show.
                isPresented = true
            }
            .credentialInput(
                isPresented: $isPresented,
                fields: .usernamePassword,
                message: String(
                    localized: "You must sign in to access '\(challengingHost)'",
                    bundle: .toolkitModule,
                    comment: """
                        A label explaining that credentials are required to authenticate with specified host.
                        The host is indicated in the variable.
                        """
                ),
                title: String(
                    localized: "Authentication Required",
                    bundle: .toolkitModule,
                    comment: "A label indicating authentication is required to proceed."
                ),
                cancelAction: .init(
                    title: .cancel,
                    handler: { _, _ in
                        onCancel()
                    }
                ),
                continueAction: .init(
                    title: .init(
                        "Continue",
                        bundle: .toolkit,
                        comment: "A label for a button used to continue the authentication operation."
                    ),
                    handler: { username, password in
                        let loginCredential = LoginCredential(
                            username: username, password: password
                        )
                        onSignIn(loginCredential)
                    }
                )
            )
    }
}

@MainActor
extension LoginViewModifier {
    /// Creates an instance from a network challenge continuation.
    init(challenge: NetworkChallengeContinuation) {
        self.init(
            challengingHost: challenge.host,
            onSignIn: { loginCredential in
                challenge.resume(
                    with: .continueWithCredential(
                        .password(
                            username: loginCredential.username,
                            password: loginCredential.password
                        )
                    )
                )
            },
            onCancel: {
                challenge.resume(with: .cancel)
            }
        )
    }
    
    /// Creates an instance from an ArcGIS challenge continuation.
    init(challenge: TokenChallengeContinuation) {
        self.init(
            challengingHost: challenge.host,
            onSignIn: { loginCredential in
                challenge.resume(with: loginCredential)
            },
            onCancel: {
                challenge.cancel()
            }
        )
    }
}
