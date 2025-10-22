// Copyright 2022 Esri
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

import Foundation
import SwiftUI

extension View {
    /// Presents user experiences for collecting credentials from the user.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    ///   - fields: The fields shown in the view.
    ///   - message: Descriptive text that provides more details about the reason for the alert.
    ///   - title: The title of the alert.
    ///   - cancelAction: The cancel action.
    ///   - continueAction: The continue action.
    @ViewBuilder func credentialInput(
        isPresented: Binding<Bool>,
        fields: CredentialInputModifier.Fields,
        message: String,
        title: String,
        cancelAction: CredentialInputModifier.Action,
        continueAction: CredentialInputModifier.Action
    ) -> some View {
        modifier(
            CredentialInputModifier(
                isPresented: isPresented,
                fields: fields,
                message: message,
                title: title,
                cancelAction: cancelAction,
                continueAction: continueAction
            )
        )
    }
}

struct CredentialInputView_Previews: PreviewProvider {
    static var previews: some View {
        Color.clear
            .credentialInput(
                isPresented: .constant(true),
                fields: .usernamePassword,
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
    
    /// A Boolean value indicating whether or not the view is displayed.
    var isPresented: Binding<Bool>
    
    /// The fields shown in the view.
    let fields: CredentialInputModifier.Fields
    
    /// Descriptive text that provides more details about the reason for the alert.
    let message: String
    
    /// The title of the alert.
    let title: String
    
    /// The cancel action.
    let cancelAction: CredentialInputModifier.Action
    
    /// The continue action.
    let continueAction: CredentialInputModifier.Action
    
    /// The value in the username field.
    @State private var username = ""
    
    /// The value in the password field.
    @State private var password = ""
    
    @FocusState private var usernameFieldIsFocused: Bool
    
    @FocusState private var passwordFieldIsFocused: Bool
    
    @ViewBuilder func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                switch fields {
                case .password:
                    passwordTextField
                case .usernamePassword:
                    usernameTextField
                    passwordTextField
                }
                
                Button(role: .cancel) {
                    cancelAction.handler("", "")
                } label: {
                    Text(cancelAction.title)
                        .padding(.horizontal)
                }
                
                Button {
                    isPresented.wrappedValue = false
                    continueAction.handler(username, password)
                } label: {
                    Text(continueAction.title)
                        .padding(.horizontal)
                }
                .disabled(!isContinueEnabled)
                
            } message: {
                Text(message)
            }
            .onAppear {
                // Reset username and password values.
                username = ""
                password = ""
                
                // Set initial focus of text field.
                switch fields {
                case .usernamePassword:
                    usernameFieldIsFocused = true
                case .password:
                    passwordFieldIsFocused = true
                }
            }
    }
}

extension CredentialInputModifier {
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
                bundle: .toolkitModule,
                comment: "A label in reference to a credential username."
            ),
            text: $username
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textContentType(.username)
        .focused($usernameFieldIsFocused)
        .submitLabel(.next)
        .onSubmit {
            passwordFieldIsFocused = true
        }
    }
    
    var passwordTextField: some View {
        SecureField(
            String(
                localized: "Password",
                bundle: .toolkitModule,
                comment: "A label in reference to a credential password."
            ),
            text: $password
        )
        .submitLabel(.done)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .textContentType(.password)
        .onSubmit {
            if isContinueEnabled {
                isPresented.wrappedValue = false
                continueAction.handler(username, password)
            }
        }
        .focused($passwordFieldIsFocused)
    }
}
extension CredentialInputModifier {
    /// The fields shown in the alert. This determines if the view is intended to require either a username
    /// and password, or a password only.
    enum Fields {
        /// Indicates the view is intended to collect a password only.
        case password
        
        /// Indicates the view is intended to collect a username and password.
        case usernamePassword
    }
}

extension CredentialInputModifier {
    /// A configuration for an alert action.
    struct Action {
        /// The title of the action.
        let title: LocalizedStringResource
        
        /// The block to execute when the action is triggered.
        /// The parameters are the username and the password.
        let handler: (String, String) -> Void
    }
}
