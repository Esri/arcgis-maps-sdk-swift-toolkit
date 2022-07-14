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

/// A type that provides the business logic for a view that prompts the user to login with a
/// username and password.
final class UsernamePasswordViewModel: ObservableObject {
    /// The username.
    @Published var username = "" {
        didSet { updateSigninButtonEnabled() }
    }
    /// The password.
    @Published var password = "" {
        didSet { updateSigninButtonEnabled() }
    }
    /// A Boolean value indicating if the sign-in button is enabled.
    @Published var signinButtonEnabled = false
    /// A Boolean value indicating if the form is enabled.
    @Published var formEnabled: Bool = true
    
    /// The action to perform when the user signs in. This is a closure that takes a username
    /// and password, respectively.
    var signInAction: (String, String) -> Void
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
        onSignIn signInAction: @escaping (String, String) -> Void,
        onCancel cancelAction: @escaping () -> Void
    ) {
        self.challengingHost = challengingHost
        self.signInAction = signInAction
        self.cancelAction = cancelAction
    }
    
    private func updateSigninButtonEnabled() {
        signinButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    /// The host that initiated the challenge.
    var challengingHost: String
    
    /// Attempts to log in with a username and password.
    func signIn() {
        formEnabled = false
        signInAction(username, password)
    }
    
    /// Cancels the challenge.
    func cancel() {
        formEnabled = false
        cancelAction()
    }
}

/// A view modifier that prompts a user to login with a username and password.
struct UsernamePasswordViewModifier: ViewModifier {
    /// The view model.
    let viewModel: UsernamePasswordViewModel
    
    /// A Boolean value indicating whether or not the prompt to login is displayed.
    @State var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .task { isPresented = true }
            .sheet(isPresented: $isPresented) {
                UsernamePasswordView(viewModel: viewModel)
            }
    }
}

extension UsernamePasswordViewModifier {
    /// Creates a `UsernamePasswordViewModifier` with a queued network challenge.
    init(challenge: QueuedNetworkChallenge) {
        self.init(
            viewModel: UsernamePasswordViewModel(
                challengingHost: challenge.host,
                onSignIn: { username, password in
                    challenge.resume(with: .useCredential(.login(username: username, password: password)))
                },
                onCancel: {
                    challenge.resume(with: .cancelAuthenticationChallenge)
                }
            )
        )
    }
    
    /// Creates a `UsernamePasswordViewModifier` with a queued ArcGIS challenge.
    init(challenge: QueuedArcGISChallenge) {
        self.init(
            viewModel: UsernamePasswordViewModel(
                challengingHost: challenge.host,
                onSignIn: { username, password in
                    Task {
                        challenge.resume(
                            with: await Result {
                                .useCredential(
                                    try await .token(
                                        challenge: challenge.arcGISChallenge,
                                        username: username,
                                        password: password
                                    )
                                )
                            }
                        )
                    }
                },
                onCancel: {
                    challenge.resume(with: .success(.cancelAuthenticationChallenge))
                }
            )
        )
    }
}

/// A view that prompts a user to login with a username and password.
private struct UsernamePasswordView: View {
    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The view model.
    init(viewModel: UsernamePasswordViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }
    
    @Environment(\.dismiss) var dismissAction
    
    /// The view model.
    @ObservedObject private var viewModel: UsernamePasswordViewModel
    
    /// The focused field.
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        person
                        Text("You must sign in to access '\(viewModel.challengingHost)'")
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
                    signinButton
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
    private var signinButton: some View {
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
        .disabled(!viewModel.signinButtonEnabled)
        .listRowBackground(viewModel.signinButtonEnabled ? Color.accentColor : Color.gray)
    }
}

private extension UsernamePasswordView {
    /// A type that represents the fields in the user name and password sign-in form.
    enum Field: Hashable {
        /// The username field.
        case username
        /// The password field.
        case password
    }
}
