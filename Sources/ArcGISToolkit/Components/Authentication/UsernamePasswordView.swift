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

@MainActor class UsernamePasswordViewModel: ObservableObject {
    init(challengingHost: String) {
        self.challengingHost = challengingHost
        continuation = nil
    }
    
    private let continuation: ChallengeContinuation?
    
    init(continuation: ChallengeContinuation) {
        self.continuation = continuation
        self.challengingHost = continuation.challenge.request.url!.host!
    }
    
    @Published var username = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var password = "" {
        didSet { updateSigninButtonEnabled() }
    }
    @Published var signinButtonEnabled = false
    
    private func updateSigninButtonEnabled() {
        signinButtonEnabled = !username.isEmpty && !password.isEmpty
    }
    
    let challengingHost: String
    
    func signIn() {
        if let continuation = continuation {
            Task {
                continuation.resume(with: await Result {
                    .useCredential(
                        try await .token(
                            challenge: continuation.challenge,
                            username: username,
                            password: password
                        )
                    )
                })
            }
        }
    }
    
    func cancel() {
        if let continuation = continuation {
            continuation.cancel()
        }
    }
}

@MainActor struct UsernamePasswordView: View {
    init(viewModel: UsernamePasswordViewModel) {
        self.viewModel = viewModel
    }
    
    private var viewModel: UsernamePasswordViewModel
    
    /// The focused field.
    @FocusState private var focusedField: Field?

    /// The username to be entered by the user.
    @State private var username = ""

    /// The password to be entered by the user.
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        person
                        Text("You need to sign in to access '\(viewModel.challengingHost)'")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Username", text: $username)
                        .focused($focusedField, equals: .username)
                        .textContentType(.username)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    SecureField("Password", text: $password)
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
            Text("Sign In")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        })
            .disabled(!viewModel.signinButtonEnabled)
            .listRowBackground(viewModel.signinButtonEnabled ? Color.accentColor : Color.gray)
    }
}

struct UsernamePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UsernamePasswordView(viewModel: UsernamePasswordViewModel(challengingHost: "arcgis.com"))
    }
}

private extension UsernamePasswordView {
    /// A type that represents the fields in the user name and password sign-in form.
    enum Field: Hashable {
        case username
        case password
    }
}
