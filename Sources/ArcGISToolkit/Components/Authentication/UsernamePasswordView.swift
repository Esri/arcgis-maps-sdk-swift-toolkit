//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import SwiftUI
import ArcGIS

@MainActor
class UsernamePasswordViewModel: ObservableObject {
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
                let disposition: Task<ArcGISAuthenticationChallenge.Disposition, Error> = Task {
                    .useCredential(
                        try await .token(
                            challenge: continuation.challenge,
                            username: username,
                            password: password
                        )
                    )
                }
                continuation.resume(with: await disposition.result)
            }
        }
    }
    
    func cancel() {
        if let continuation = continuation {
            continuation.cancel()
        }
    }
}

struct UsernamePasswordView: View {
    init(viewModel: UsernamePasswordViewModel) {
        self.viewModel = viewModel
    }
    
    var viewModel: UsernamePasswordViewModel
    
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
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .shadow(
                                color: .gray.opacity(0.4),
                                radius: 3,
                                x: 1,
                                y: 2
                            )
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
}

struct UsernamePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        UsernamePasswordView(viewModel: UsernamePasswordViewModel(challengingHost: "arcgis.com"))
    }
}

private extension UsernamePasswordView {
    /// The field to set the focus.
    enum Field: Hashable {
        case username
        case password
    }
}
