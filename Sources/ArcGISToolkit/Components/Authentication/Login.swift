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
            .task { isPresented = true }
            .overlay {
                LoginView(
                    viewModel: viewModel,
                    isPresented: $isPresented
                )
            }
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
                        with: .useCredential(
                            .password(username: loginCredential.username, password: loginCredential.password)
                        )
                    )
                },
                onCancel: {
                    challenge.resume(with: .cancelAuthenticationChallenge)
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

/// A view that prompts a user to login with a username and password.
///
/// Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
private struct LoginView: UIViewControllerRepresentable {
    /// The view model.
    @ObservedObject var viewModel: LoginViewModel
    
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding var isPresented: Bool
    
    /// The cancel action for the `UIAlertController`.
    let cancelAction: UIAlertAction
    
    /// The sign in action for the `UIAlertController`.
    let signInAction: UIAlertAction
    
    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The view model.
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    init(viewModel: LoginViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        
        _isPresented = isPresented
        
        cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            viewModel.cancel()
        }
        signInAction = UIAlertAction(title: "Sign In", style: .default) { _ in
            viewModel.signIn()
        }
        
        cancelAction.isEnabled = true
        signInAction.isEnabled = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Creates the alert controller object and configures its initial state.
    /// - Parameter context: A context structure containing information about the current state of the
    /// system.
    /// - Returns: A configured alert controller.
    func makeAlertController(context: Context) -> UIAlertController {
        let uiAlertController = UIAlertController(
            title: "Authentication Required",
            message: "You must sign in to access '\(viewModel.challengingHost)'",
            preferredStyle: .alert
        )
        
        uiAlertController.addTextField { textField in
            textField.addAction(
                UIAction { _ in
                    viewModel.username = textField.text ?? ""
                    signInAction.isEnabled = viewModel.signInButtonEnabled
                },
                for: .editingChanged
            )
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.placeholder = "Username"
            textField.returnKeyType = .next
            textField.textContentType = .username
        }
        
        uiAlertController.addTextField { textField in
            textField.addAction(
                UIAction { _ in
                    viewModel.password = textField.text ?? ""
                    signInAction.isEnabled = viewModel.signInButtonEnabled
                },
                for: .editingChanged
            )
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
            textField.returnKeyType = .go
            textField.textContentType = .password
        }
        
        uiAlertController.addAction(cancelAction)
        uiAlertController.addAction(signInAction)
        
        return uiAlertController
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        guard isPresented else { return }
        let alertController = makeAlertController(context: context)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            uiViewController.present(alertController, animated: true) {
                isPresented = false
            }
        }
    }
}

extension LoginView {
    /// The coordinator for the login view that acts as a delegate to the underlying
    /// `UIAlertViewController`.
    final class Coordinator: NSObject, UITextFieldDelegate {
        /// The view that owns this coordinator.
        let parent: LoginView
        
        /// Creates the coordinator.
        /// - Parameter parent: The view that owns this coordinator.
        init(_ parent: LoginView) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard parent.viewModel.signInButtonEnabled else {
                return false
            }
            parent.viewModel.signIn()
            return true
        }
    }
}
