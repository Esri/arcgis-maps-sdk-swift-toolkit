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
import UniformTypeIdentifiers
import ArcGIS

/// An object that provides the business logic for the workflow of prompting the user for a
/// certificate and a password.
@MainActor final class CertificatePickerViewModel: ObservableObject {
    /// The challenge that requires a certificate to proceed.
    let challenge: NetworkChallengeContinuation
    
    /// The URL of the certificate that the user chose.
    var certificateURL: URL?
    
    /// The password.
    @Published var password = ""
    
    /// A Boolean value indicating whether to show the prompt.
    @Published var showPrompt = true
    
    /// A Boolean value indicating whether to show the certificate file picker.
    @Published var showPicker = false
    
    /// A Boolean value indicating whether to show the password field view.
    @Published var showPassword = false
    
    /// A Boolean value indicating whether to display the error.
    @Published var showCertificateImportError = false
    
    /// The certificate import error that occurred.
    var certificateImportError: CertificateImportError?
    
    /// The host that prompted the challenge.
    var challengingHost: String {
        challenge.host
    }
    
    /// Creates a certificate picker view model.
    /// - Parameter challenge: The challenge that requires a certificate.
    init(challenge: NetworkChallengeContinuation) {
        self.challenge = challenge
    }
    
    /// Proceeds to show the file picker. This should be called after the prompt that notifies the
    /// user that a certificate must be selected.
    func proceedFromPrompt() {
        showPicker = true
    }
    
    /// Proceeds to show the user the password form. This should be called after the user selects
    /// a certificate.
    /// - Parameter url: The URL of the certificate that the user chose.
    func proceed(withCertificateURL url: URL) {
        certificateURL = url
        showPassword = true
    }
    
    /// Attempts to use the certificate and password to respond to the challenge.
    func proceedWithPassword() {
        guard let certificateURL = certificateURL, !password.isEmpty else {
            preconditionFailure()
        }
        
        Task {
            do {
                challenge.resume(with: .useCredential(try .certificate(at: certificateURL, password: password)))
            } catch {
                // This is required to prevent an "already presenting" error.
                try? await Task.sleep(nanoseconds: 100_000)
                certificateImportError = error as? CertificateImportError
                showCertificateImportError = true
            }
        }
    }
    
    /// Cancels the challenge.
    func cancel() {
        challenge.resume(with: .cancelAuthenticationChallenge)
    }
}

/// A view modifier that presents a certificate picker workflow.
struct CertificatePickerViewModifier: ViewModifier {
    /// Creates a certificate picker view modifier.
    /// - Parameter challenge: The challenge that requires a certificate.
    init(challenge: NetworkChallengeContinuation) {
        viewModel = CertificatePickerViewModel(challenge: challenge)
    }
    
    /// The view model.
    @ObservedObject private var viewModel: CertificatePickerViewModel
    
    func body(content: Content) -> some View {
        content
            .promptBrowseCertificate(
                isPresented: $viewModel.showPrompt,
                viewModel: viewModel
            )
            .certificateFilePicker(
                isPresented: $viewModel.showPicker,
                viewModel: viewModel
            )
            .passwordSheet(
                isPresented: $viewModel.showPassword,
                viewModel: viewModel
            )
            .alertCertificateImportError(
                isPresented: $viewModel.showCertificateImportError,
                viewModel: viewModel
            )
    }
}

private extension UTType {
    /// A `UTType` that represents a pfx file.
    static let pfx = UTType(filenameExtension: "pfx")!
}

private extension View {
    /// Displays a prompt to the user to let them know that picking a certificate is required.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func promptBrowseCertificate(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        alert("Certificate Required", isPresented: isPresented, presenting: viewModel.challengingHost) { _ in
            Button("Browse For Certificate") {
                viewModel.proceedFromPrompt()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancel()
            }
        } message: { _ in
            Text("A certificate is required to access content on \(viewModel.challengingHost).")
        }
    }
}

private extension View {
    /// Displays a sheet that allows the user to select a certificate file.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func certificateFilePicker(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        sheet(isPresented: isPresented) {
            DocumentPickerView(contentTypes: [.pfx]) {
                viewModel.proceed(withCertificateURL: $0)
            } onCancel: {
                viewModel.cancel()
            }
            .edgesIgnoringSafeArea(.bottom)
            .interactiveDismissDisabled()
        }
    }
}

private extension View {
    /// Displays a sheet that allows the user to enter a password.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func passwordSheet(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        overlay {
            EnterPasswordView(
                viewModel: viewModel,
                isPresented: isPresented
            )
        }
    }
}

private extension View {
    /// Displays an alert to notify that there was an error importing the certificate.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func alertCertificateImportError(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        
        alert("Error importing certificate", isPresented: isPresented) {
            Button("Try Again") {
                viewModel.proceedFromPrompt()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancel()
            }
        } message: {
            Text(message(for: viewModel.certificateImportError))
        }
    }
    
    func message(for error: CertificateImportError?) -> String {
        let defaultMessage = "The certificate file or password was invalid."
        guard let error = error else {
            return defaultMessage
        }
        
        switch error {
        case .invalidData:
            return "The certificate file was invalid."
        case .invalidPassword:
            return "The password was invalid."
        default:
            return defaultMessage
        }
    }
}

/// A view that allows the user to enter a password.
///
/// Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
struct EnterPasswordView: UIViewControllerRepresentable {
    /// The view model.
    @ObservedObject var viewModel: CertificatePickerViewModel
    
    /// A Boolean value indicating whether or not the view is displayed.
    @Binding var isPresented: Bool
    
    /// The cancel action for the `UIAlertController`.
    @State var cancelAction: UIAlertAction
    
    /// The continue action for the `UIAlertController`.
    @State var continueAction: UIAlertAction
    
    /// Creates the view.
    /// - Parameters:
    ///   - viewModel: The view model.
    ///   - isPresented: A Boolean value indicating whether or not the view is displayed.
    init(
        viewModel: CertificatePickerViewModel,
        isPresented: Binding<Bool>
    ) {
        self.viewModel = viewModel
        
        _isPresented = isPresented
        
        cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            viewModel.cancel()
        }
        continueAction = UIAlertAction(title: "OK", style: .default) { _ in
            viewModel.proceedWithPassword()
        }
        
        cancelAction.isEnabled = true
        continueAction.isEnabled = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Creates the alert controller object and configures its initial state.
    /// - Parameter context: A context structure containing information about the current state of the
    /// system.
    /// - Returns: A configured alert controller.
    func makeAlertController(context: Context) -> UIAlertController {
        let uiAlertController = UIAlertController(
            title: "Password Required",
            message: "Please enter a password for the chosen certificate.",
            preferredStyle: .alert
        )
        
        uiAlertController.addTextField { textField in
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.delegate = context.coordinator
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
            textField.returnKeyType = .go
            textField.textContentType = .password
        }
        
        uiAlertController.addAction(cancelAction)
        uiAlertController.addAction(continueAction)
        
        return uiAlertController
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) {
        if isPresented {
            let alertController = makeAlertController(context: context)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                uiViewController.present(alertController, animated: true) {
                    isPresented = false
                }
            }
        }
    }
}

extension EnterPasswordView {
    /// The coordinator for the password view that acts as a delegate to the underlying
    /// `UIAlertViewController`.
    final class Coordinator: NSObject, UITextFieldDelegate {
        /// The view that owns this coordinator.
        let parent: EnterPasswordView
        
        /// Creates the coordinator.
        /// - Parameter parent: The view that owns this coordinator.
        init(_ parent: EnterPasswordView) {
            self.parent = parent
        }
        
        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateValues(with: textField)
            }
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if !parent.viewModel.password.isEmpty {
                parent.viewModel.proceedWithPassword()
            }
            return true
        }
        
        /// Updates the view model with the latest text field values and the enabled state of the continue
        /// button.
        /// - Parameter textField: The text field who's value recently changed.
        func updateValues(with textField: UITextField) {
            parent.viewModel.password = textField.text ?? ""
            parent.continueAction.isEnabled = !parent.viewModel.password.isEmpty
        }
    }
}
