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

import Foundation
import SwiftUI

extension View {
    /// Presents user experiences for collecting credentials from the user.
    /// - Parameters:
    ///   - fields: The fields shown in the view.
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    ///   - message: Descriptive text that provides more details about the reason for the alert.
    ///   - title: The title of the alert.
    ///   - cancelAction: The cancel action.
    ///   - continueAction: The continue action.
    @ViewBuilder func credentialInput(
        fields: CredentialInputSheetView.Fields,
        isPresented: Binding<Bool>,
        message: String,
        title: String,
        cancelAction: CredentialInputSheetView.Action,
        continueAction: CredentialInputSheetView.Action
    ) -> some View {
        modifier(
            CredentialInputModifier(
                fields: fields,
                isPresented: isPresented,
                message: message,
                title: title,
                cancelAction: cancelAction,
                continueAction: continueAction
            )
        )
    }
}

struct CredentialInputSheetView_Previews: PreviewProvider {
    static var previews: some View {
        Text("foo")
        .credentialInput(
            fields: .usernamePassword,
            isPresented: .constant(true),
            message: "You must sign in to access 'arcgis.com'",
            title: "Authentication Required",
            cancelAction: .init(
                title: "Cancel",
                handler: { _, _ in
                    
                }
            ),
            continueAction: .init(
                title: "Continue",
                handler: { username, password in
                }
            )
        )
    }
}

/// A view modifier that prompts for credentials.
struct CredentialInputModifier: ViewModifier {
    
    /// The fields shown in the view.
    let fields: CredentialInputSheetView.Fields
    
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding var isPresented: Bool
    
    /// Descriptive text that provides more details about the reason for the alert.
    let message: String
    
    /// The title of the alert.
    let title: String
    
    /// The cancel action.
    let cancelAction: CredentialInputSheetView.Action
    
    /// The continue action.
    let continueAction: CredentialInputSheetView.Action
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                CredentialInputSheetView(
                    fields: fields,
                    message: message,
                    title: title,
                    cancelAction: cancelAction,
                    continueAction: continueAction
                )
                .mediumPresentationDetents()
            }
    }
}

struct CredentialInputSheetView: View {
    /// The fields shown in the alert.
    private let fields: Fields
    
    /// Descriptive text that provides more details about the reason for the alert.
    private let message: String
    
    /// The title of the alert.
    private let title: String
    
    /// The cancel action.
    private let cancelAction: Action
    
    /// The continue action.
    private let continueAction: Action
    
    /// The value in the username field.
    ///
    /// This member is unused when usage is set to `Usage.passwordOnly`.
    @State private var username = ""

    /// The value in the password field.
    @State private var password = ""
    
    /// Creates the view.
    /// - Parameters:
    ///   - fields: The fields shown in the alert.
    ///   - message: Descriptive text that provides more details about the reason for the alert.
    ///   - title: The title of the alert.
    ///   - cancelAction: The cancel action.
    ///   - continueAction: The continue action.
    init(
        fields: Fields,
        message: String,
        title: String,
        cancelAction: Action,
        continueAction: Action
    ) {
        self.cancelAction = cancelAction
        self.continueAction = continueAction
        
        self.fields = fields
        self.message = message
        self.title = title
    }
    
    /// A Boolean value indicating whether the alert should allow the continue action to proceed.
    private var isContinueEnabled: Bool {
        switch fields {
        case .usernamePassword:
            return !username.isEmpty && !password.isEmpty
        case .password:
            return !password.isEmpty
        }
    }
    
    var usernameTextField: some View {
        TextField(
            String(
                localized: "Username",
                bundle: .toolkitModule
            ),
            text: $username
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textContentType(.username)
    }
    
    var passwordTextField: some View {
        SecureField(
            String(
                localized: "Password",
                bundle: .toolkitModule
            ),
            text: $password
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textContentType(.password)
        .onSubmit {
            if isContinueEnabled {
                continueAction.handler(username, password)
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 2) {
                Text(title)
                    .font(.title)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .padding([.top, .horizontal])
            VStack {
                switch fields {
                case .password:
                    passwordTextField
                case .usernamePassword:
                    usernameTextField
                    Divider()
                    passwordTextField
                }
                Divider()
                    .padding(.bottom)
                HStack {
                    Spacer()
                    Button(role: .cancel) {
                        cancelAction.handler(username, password)
                    } label: {
                        Text(cancelAction.title)
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Divider()
                    Spacer()
                    Button(continueAction.title) {
                        continueAction.handler(username, password)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isContinueEnabled)
                    Spacer()
                }
                .padding(.top)
                .frame(maxHeight: 36)
                Spacer()
            }
            .padding()
            Spacer()
        }
        .padding()
    }
}
extension CredentialInputSheetView {
    /// The fields shown in the alert. This determines if the view is intended to require either a username
    /// and password, or a password only.
    enum Fields {
        /// Indicates the view is intended to collect a password only.
        case password
        
        /// Indicates the view is intended to collect a username and password.
        case usernamePassword
    }
}

extension CredentialInputSheetView {
    /// A configuration for an alert action.
    struct Action {
        /// The title of the action.
        let title: String
        
        /// The block to execute when the action is triggered.
        let handler: (String, String) -> Void
    }
}
