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
import ArcGIS

/// A value that contains a username and password pair.
struct LoginCredential: Hashable {
    /// The username.
    let username: String
    
    /// The password.
    let password: String
}

/// A type that provides the business logic for a view that prompts the user to login with a
/// username and password.
@MainActor
final class LoginViewModel: ObservableObject {
    /// The username.
    @Published var username = "" {
        didSet { updateSignInButtonEnabled() }
    }
    
    /// The password.
    @Published var password = "" {
        didSet { updateSignInButtonEnabled() }
    }
    
    /// A Boolean value indicating if the sign-in button is enabled.
    @Published var signInButtonEnabled = false
    
    /// The action to perform when the user signs in. This is a closure that takes a username
    /// and password, respectively.
    var signInAction: (LoginCredential) -> Void
    
    /// The action to perform when the user cancels.
    var cancelAction: () -> Void
    
    /// Creates a `UsernamePasswordViewModel`.
    /// - Parameters:
    ///   - challengingHost: The host that prompted the challenge.
    ///   - signInAction: The action to perform when the user signs in. This is a closure that takes
    ///    a username and password, respectively.
    ///   - cancelAction: The action to perform when the user cancels.
    init(
        challengingHost: String,
        onSignIn signInAction: @escaping (LoginCredential) -> Void,
        onCancel cancelAction: @escaping () -> Void
    ) {
        self.challengingHost = challengingHost
        self.signInAction = signInAction
        self.cancelAction = cancelAction
    }
    
    private func updateSignInButtonEnabled() {
        signInButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    /// The host that initiated the challenge.
    var challengingHost: String
    
    /// Attempts to log in with a username and password.
    func signIn() {
        signInAction(LoginCredential(username: username, password: password))
    }
    
    /// Cancels the challenge.
    func cancel() {
        cancelAction()
    }
}

/// A view modifier that prompts a user to login with a username and password.
struct LoginViewModifier: ViewModifier {
    /// The view model.
    let viewModel: LoginViewModel
    
    /// A Boolean value indicating whether or not the prompt to login is displayed.
    @State var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .onAppear { isPresented = true }
            .credentialInput(
                fields: .usernamePassword,
                isPresented: $isPresented,
                message: "You must sign in to access '\(viewModel.challengingHost)'",
                title: "Authentication Required",
                cancelAction: .init(
                    title: "Cancel",
                    handler: { _, _ in
                        viewModel.cancel()
                    }
                ),
                continueAction: .init(
                    title: "Continue",
                    handler: { username, password in
                        viewModel.username = username
                        viewModel.password = password
                        viewModel.signIn()
                    }
                )
            )
    }
}

extension LoginViewModifier {
    /// Creates a `LoginViewModifier` with a network challenge continuation.
    @MainActor init(challenge: NetworkChallengeContinuation) {
        self.init(
            viewModel: LoginViewModel(
                challengingHost: challenge.host,
                onSignIn: { loginCredential in
                    challenge.resume(
                        with: .continueWithCredential(
                            .password(username: loginCredential.username, password: loginCredential.password)
                        )
                    )
                },
                onCancel: {
                    challenge.resume(with: .cancel)
                }
            )
        )
    }
    
    /// Creates a `LoginViewModifier` with an ArcGIS challenge continuation.
    @MainActor init(challenge: TokenChallengeContinuation) {
        self.init(
            viewModel: LoginViewModel(
                challengingHost: challenge.host,
                onSignIn: { loginCredential in
                    challenge.resume(with: loginCredential)
                },
                onCancel: {
                    challenge.cancel()
                }
            )
        )
    }
}
