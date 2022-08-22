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

/// A view that prompts a user to login with a username and password.
///
/// Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
struct RequiredInputAlertView: UIViewControllerRepresentable {
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding private var isPresented: Bool
    
    /// <#Description#>
    @State var fieldOne = ""
    
    /// <#Description#>
    @State var fieldTwo = ""
    
    /// <#Description#>
    private let style: Style
    
    /// <#Description#>
    private let title: String
    
    /// <#Description#>
    private let message: String
    
    /// <#Description#>
    private let cancelConfiguration: ActionConfiguration
    
    /// <#Description#>
    private let continueConfiguration: ActionConfiguration
    
    /// <#Description#>
    /// - Parameters:
    ///   - isPresented: <#isPresented description#>
    ///   - style: <#style description#>
    ///   - title: <#title description#>
    ///   - message: <#message description#>
    ///   - cancelConfiguration: <#cancelConfiguration description#>
    ///   - continueConfiguration: <#continueConfiguration description#>
    init(
        isPresented: Binding<Bool>,
        style: Style,
        title: String,
        message: String,
        cancelConfiguration: ActionConfiguration,
        continueConfiguration: ActionConfiguration
    ) {
        _isPresented = isPresented
        
        self.style = style
        
        self.cancelConfiguration = cancelConfiguration
        
        self.continueConfiguration = continueConfiguration
        
        self.title = title
        
        self.message = message
    }
    
    /// <#Description#>
    var isContinueEnabled: Bool {
        !fieldOne.isEmpty && !fieldTwo.isEmpty
    }
    
    /// <#Description#>
    /// - Parameter context: <#context description#>
    /// - Returns: <#description#>
    func makeAlertController(context: Context) -> UIAlertController {
        let uiAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: cancelConfiguration.title, style: .cancel) { _ in
            cancelConfiguration.handler(fieldOne, fieldTwo)
        }
        
        let continueAction = UIAlertAction(title: continueConfiguration.title, style: .default) { _ in
            continueConfiguration.handler(fieldOne, fieldTwo)
        }
        
        if style == .identityAndPassword {
            uiAlertController.addTextField { textField in
                textField.addAction(
                    UIAction { _ in
                        fieldOne = textField.text ?? ""
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
                    fieldTwo = textField.text ?? ""
                    continueAction.isEnabled = isContinueEnabled
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

extension RequiredInputAlertView {
    /// The coordinator for the login view that acts as a delegate to the underlying
    /// `UIAlertViewController`.
    final class Coordinator: NSObject, UITextFieldDelegate {
        /// The view that owns this coordinator.
        let parent: RequiredInputAlertView
        
        /// Creates the coordinator.
        /// - Parameter parent: The view that owns this coordinator.
        init(_ parent: RequiredInputAlertView) {
            self.parent = parent
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard !parent.fieldTwo.isEmpty else {
                return false
            }
            parent.continueConfiguration.handler(parent.fieldOne, parent.fieldTwo)
            return true
        }
    }
}

extension RequiredInputAlertView {
    /// <#Description#>
    struct ActionConfiguration {
        /// <#Description#>
        let title: String
        
        /// <#Description#>
        let handler: (String, String) -> Void
    }
}

extension RequiredInputAlertView {
    /// <#Description#>
    enum Style {
        ///
        case identityAndPassword
        
        ///
        case passwordOnly
    }
}
