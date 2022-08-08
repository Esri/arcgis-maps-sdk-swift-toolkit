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
    
    /// A Boolean value indicating if the form is enabled.
    @Published var formEnabled: Bool = true
    
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
        formEnabled = false
        signInAction(LoginCredential(username: username, password: password))
    }
    
    /// Cancels the challenge.
    func cancel() {
        formEnabled = false
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
            .sheet(isPresented: $isPresented) {
                LoginView(viewModel: viewModel)
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
private struct LoginView: View {
    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The view model.
    init(viewModel: LoginViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }
    
    @Environment(\.dismiss) var dismissAction
    
    /// The view model.
    @ObservedObject private var viewModel: LoginViewModel
    
    /// The focused field.
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        person
                        Text("You must sign in to access '\(viewModel.challengingHost)'")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    TextField("Username", text: $viewModel.username)
                        .focused($focusedField, equals: .username)
                        .textContentType(.username)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    SecureField("Password", text: $viewModel.password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit { viewModel.signIn() }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Section {
                    signInButton
                }
            }
            .disabled(!viewModel.formEnabled)
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAction()
                        viewModel.cancel()
                    }
                }
            }
            .onAppear {
                // Workaround for Apple bug - FB9676178.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    focusedField = .username
                }
            }
        }
    }
    
    /// An image used in the form.
    private var person: some View {
        Image(systemName: "person.circle")
            .resizable()
            .frame(width: 150, height: 150)
            .shadow(
                color: .gray.opacity(0.4),
                radius: 3,
                x: 1,
                y: 2
            )
    }
    
    /// The sign-in button.
    private var signInButton: some View {
        Button(action: {
            dismissAction()
            viewModel.signIn()
        }, label: {
            if viewModel.formEnabled {
                Text("Sign In")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.white)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .tint(.white)
            }
        })
        .disabled(!viewModel.signInButtonEnabled)
        .listRowBackground(viewModel.signInButtonEnabled ? Color.accentColor : Color.gray)
    }
}

private extension LoginView {
    /// A type that represents the fields in the user name and password sign-in form.
    enum Field: Hashable {
        /// The username field.
        case username
        /// The password field.
        case password
    }
}
