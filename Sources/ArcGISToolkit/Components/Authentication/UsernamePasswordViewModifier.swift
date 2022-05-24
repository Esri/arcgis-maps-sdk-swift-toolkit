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

protocol UsernamePasswordViewModel: ObservableObject {
    var username: String { get set }
    var password: String { get set }
    var signinButtonEnabled: Bool { get }
    var formEnabled: Bool { get }
    var challengingHost: String { get }
    
    func signIn()
    func cancel()
}

struct UsernamePasswordViewModifier<ViewModel: UsernamePasswordViewModel>: ViewModifier {
    let viewModel: ViewModel
    
    init(challenge: QueuedURLChallenge) where ViewModel == URLCredentialUsernamePasswordViewModel {
        viewModel = URLCredentialUsernamePasswordViewModel(challenge: challenge)
    }
    
    init(challenge: QueuedArcGISChallenge) where ViewModel == TokenCredentialViewModel {
        viewModel = TokenCredentialViewModel(challenge: challenge)
    }
    
    @State var isPresented = false
    
    func body(content: Content) -> some View {
        content
            .sheet { UsernamePasswordView(viewModel: viewModel) }
    }
}

private struct UsernamePasswordView<ViewModel: UsernamePasswordViewModel>: View {
    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }
    
    @ObservedObject private var viewModel: ViewModel
    
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
                    Button("Cancel") { viewModel.cancel() }
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
    
    private var signinButton: some View {
        Button(action: {
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

struct UsernamePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UsernamePasswordView(viewModel: MockUsernamePasswordViewModel(challengingHost: "arcgis.com"))
    }
}

private extension UsernamePasswordView {
    /// A type that represents the fields in the user name and password sign-in form.
    enum Field: Hashable {
        case username
        case password
    }
}

class MockUsernamePasswordViewModel: UsernamePasswordViewModel {
    init(challengingHost: String) {
        self.challengingHost = challengingHost
    }
    
    @Published var username = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var password = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var signinButtonEnabled = false
    @Published var formEnabled: Bool = true
    
    private func updateSigninButtonEnabled() {
        signinButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    let challengingHost: String
    
    func signIn() {
        formEnabled = false
    }
    
    func cancel() {
        formEnabled = false
    }
}

class TokenCredentialViewModel: UsernamePasswordViewModel {
    private let challenge: QueuedArcGISChallenge
    
    init(challenge: QueuedArcGISChallenge) {
        self.challenge = challenge
    }
    
    @Published var username = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var password = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var signinButtonEnabled = false
    @Published var formEnabled: Bool = true
    
    private func updateSigninButtonEnabled() {
        signinButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    var challengingHost: String {
        challenge.arcGISChallenge.request.url!.host!
    }
    
    func signIn() {
        formEnabled = false
        challenge.resume(with: .tokenCredential(username: username, password: password))
    }
    
    func cancel() {
        formEnabled = false
        challenge.cancel()
    }
}

class URLCredentialUsernamePasswordViewModel: UsernamePasswordViewModel {
    private let challenge: QueuedURLChallenge
    
    init(challenge: QueuedURLChallenge) {
        self.challenge = challenge
    }
    
    @Published var username = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var password = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var signinButtonEnabled = false
    @Published var formEnabled: Bool = true
    
    private func updateSigninButtonEnabled() {
        signinButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    var challengingHost: String {
        challenge.urlChallenge.protectionSpace.host
    }
    
    func signIn() {
        formEnabled = false
        challenge.resume(with: .userCredential(username: username, password: password))
    }
    
    func cancel() {
        formEnabled = false
        challenge.cancel()
    }
}
