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

/// A view that prompts a user to provide credentials. It can be configured to require either a username and
/// password, or a password only.
///
/// The view is implemented as a wrapper for a UIKit `UIAlertController` because as of iOS 16,
/// SwiftUI alerts don't support visible but disabled buttons.
struct CredentialInputView: UIViewControllerRepresentable {
    /// The cancel action.
    private let cancelAction: Action
    
    /// The continue action.
    private let continueAction: Action
    
    /// The value in the username field.
    ///
    /// This member is unused when usage is set to `Usage.passwordOnly`.
    @State private var username = ""
    
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding private var isPresented: Bool
    
    /// Descriptive text that provides more details about the reason for the alert.
    private let message: String
    
    /// The value in the password field.
    @State private var password = ""
    
    /// The title of the alert.
    private let title: String
    
    /// The fields shown in the alert.
    private let fields: Fields
    
    /// Creates the view.
    /// - Parameters:
    ///   - fields: The fields shown in the alert.
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    ///   - message: Descriptive text that provides more details about the reason for the alert.
    ///   - title: The title of the alert.
    ///   - cancelAction: The cancel action.
    ///   - continueAction: The continue action.
    init(
        fields: Fields,
        isPresented: Binding<Bool>,
        message: String,
        title: String,
        cancelAction: Action,
        continueAction: Action
    ) {
        self.cancelAction = cancelAction
        self.continueAction = continueAction
        
        _isPresented = isPresented
        
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
    
    /// Creates the alert controller.
    /// - Parameter context: A context structure containing information about the current state of the
    /// system.
    /// - Returns: The alert controller displayed to the user.
    private func makeAlertController(context: Context) -> UIAlertController {
        let uiAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let cancelUIAlertAction = UIAlertAction(
            title: cancelAction.title,
            style: .cancel
        ) { _ in
            cancelAction.handler(username, password)
        }
        
        let continueUIAlertAction = UIAlertAction(
            title: continueAction.title,
            style: .default
        ) { _ in
            continueAction.handler(username, password)
        }
        
        if fields == .usernamePassword {
            uiAlertController.addTextField { textField in
                textField.addAction(
                    UIAction { _ in
                        username = textField.text ?? ""
                        continueUIAlertAction.isEnabled = isContinueEnabled
                    },
                    for: .editingChanged
                )
                textField.autocapitalizationType = .none
                textField.autocorrectionType = .no
                textField.placeholder = "Username"
                textField.returnKeyType = .next
                textField.textContentType = .username
            }
        }
        
        uiAlertController.addTextField { textField in
            textField.addAction(
                UIAction { _ in
                    password = textField.text ?? ""
                    continueUIAlertAction.isEnabled = isContinueEnabled
                },
                for: .editingChanged
            )
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            
            // Add a coordinator to the password field so that the primary
            // keyboard action can be disabled when the field is empty.
            textField.delegate = context.coordinator
            
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
            textField.returnKeyType = .go
            textField.textContentType = .password
        }
        
        cancelUIAlertAction.isEnabled = true
        continueUIAlertAction.isEnabled = false
        
        uiAlertController.addAction(cancelUIAlertAction)
        uiAlertController.addAction(continueUIAlertAction)
        
        return uiAlertController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        guard isPresented else { return }
        let alertController = makeAlertController(context: context)
        // On a physical iOS 16 device, without the following delay, the
        // presentation fails and the following warning is logged: "Attempt to
        // present UIAlertController on UIViewController whose view is not in
        // the window hierarchy."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            uiViewController.present(alertController, animated: true) {
                isPresented = false
            }
        }
    }
}

extension CredentialInputView {
    /// The coordinator for the login view that acts as a delegate to the underlying
    /// `UIAlertViewController`.
    final class Coordinator: NSObject, UITextFieldDelegate {
        /// The view that owns this coordinator.
        let parent: CredentialInputView
        
        /// Creates the coordinator.
        /// - Parameter parent: The view that owns this coordinator.
        init(_ parent: CredentialInputView) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard !parent.password.isEmpty else { return false }
            parent.continueAction.handler(
                parent.username,
                parent.password
            )
            return true
        }
    }
}

extension CredentialInputView {
    /// A configuration for an alert action.
    struct Action {
        /// The title of the action.
        let title: String
        
        /// The block to execute when the action is triggered.
        let handler: (String, String) -> Void
    }
}

extension CredentialInputView {
    /// The fields shown in the alert. This determines if the view is intended to require either a username
    /// and password, or a password only.
    enum Fields {
        /// Indicates the view is intended to collect a password only.
        case password
        
        /// Indicates the view is intended to collect a username and password.
        case usernamePassword
    }
}

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
        fields: CredentialInputView.Fields,
        isPresented: Binding<Bool>,
        message: String,
        title: String,
        cancelAction: CredentialInputView.Action,
        continueAction: CredentialInputView.Action
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

/// A view modifier that prompts for credentials.
struct CredentialInputModifier: ViewModifier {
    
    /// The fields shown in the view.
    let fields: CredentialInputView.Fields
    
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding var isPresented: Bool
    
    /// Descriptive text that provides more details about the reason for the alert.
    let message: String
    
    /// The title of the alert.
    let title: String
    
    /// The cancel action.
    let cancelAction: CredentialInputView.Action
    
    /// The continue action.
    let continueAction: CredentialInputView.Action
    
    @ViewBuilder func body(content: Content) -> some View {
        ZStack {
            content
            CredentialInputView(
                fields: fields,
                isPresented: $isPresented,
                message: message,
                title: title,
                cancelAction: cancelAction,
                continueAction: continueAction
            )
        }
    }
}
