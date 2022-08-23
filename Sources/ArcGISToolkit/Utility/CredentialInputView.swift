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

/// A view that prompts a user to provide credentials. It can be configured to require either an identity and
/// password, or a password only.
///
/// The view is implemented as a wrapper for a UIKit `UIAlertController` because as of iOS 16,
/// SwiftUI alerts don't support visible but disabled buttons.
struct CredentialInputView: UIViewControllerRepresentable {
    /// The cancel action configuration.
    private let cancelConfiguration: Action
    
    /// The continue action configuration.
    private let continueConfiguration: Action
    
    /// The value in the identity field.
    ///
    /// This member is unused when usage is set to `Usage.passwordOnly`.
    @State private var identity = ""
    
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
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    ///   - message: Descriptive text that provides more details about the reason for the alert.
    ///   - title: The title of the alert.
    ///   - fields: The fields shown in the alert.
    ///   - cancelConfiguration: The cancel action configuration.
    ///   - continueConfiguration: The continue action configuration.
    init(
        fields: Fields,
        isPresented: Binding<Bool>,
        message: String,
        title: String,
        cancelConfiguration: Action,
        continueConfiguration: Action
    ) {
        self.cancelConfiguration = cancelConfiguration
        self.continueConfiguration = continueConfiguration
        
        _isPresented = isPresented
        
        self.fields = fields
        self.message = message
        self.title = title
    }
    
    /// A Boolean value indicating whether the alert should allow the continue action to proceed.
    private var isContinueEnabled: Bool {
        switch fields {
        case .identityAndPassword:
            return !identity.isEmpty && !password.isEmpty
        case .passwordOnly:
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
        
        let cancelAction = UIAlertAction(
            title: cancelConfiguration.title,
            style: .cancel
        ) { _ in
            cancelConfiguration.handler(identity, password)
        }
        
        let continueAction = UIAlertAction(
            title: continueConfiguration.title,
            style: .default
        ) { _ in
            continueConfiguration.handler(identity, password)
        }
        
        if fields == .identityAndPassword {
            uiAlertController.addTextField { textField in
                textField.addAction(
                    UIAction { _ in
                        identity = textField.text ?? ""
                        continueAction.isEnabled = isContinueEnabled
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
                    continueAction.isEnabled = isContinueEnabled
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
        
        cancelAction.isEnabled = true
        continueAction.isEnabled = false
        
        uiAlertController.addAction(cancelAction)
        uiAlertController.addAction(continueAction)
        
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
        // presentation fails and an error is thrown.
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
            parent.continueConfiguration.handler(
                parent.identity,
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
    /// The usage of the view. This determines if the view is intended to require either an identity and
    /// password, or a password only.
    enum Fields {
        /// Indicates the view is intended to collect an identity and password.
        case identityAndPassword
        
        /// Indicates the view is intended to collect a password only.
        case passwordOnly
    }
}
