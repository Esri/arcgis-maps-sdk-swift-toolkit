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

/// An object that provides the business logic for the workflow of prompting the user for a
/// certificate and a password.
@MainActor
final private class CertificatePickerViewModel: ObservableObject {
    /// The challenge that requires a certificate to proceed.
    let challenge: QueuedNetworkChallenge
    
    /// The URL of the certificate that the user chose.
    private var certificateURL: URL?
    
    /// A Boolean value indicating whether to show the prompt.
    @Published var showPrompt = true
    /// A Boolean value indicating whether to show the certificate file picker.
    @Published var showPicker = false
    /// A Boolean value indicating whether to show the password field view.
    @Published var showPassword = false
    /// A Boolean value indicating whether to display the error.
    @Published var showCertificateImportError = false
    
    /// The host that prompted the challenge.
    var challengingHost: String {
        challenge.host
    }
    
    /// Creates a certificate picker view model.
    /// - Parameter challenge: The challenge that requires a certificate.
    init(challenge: QueuedNetworkChallenge) {
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
    /// - Parameter password: The password for the certificate.
    func proceed(withPassword password: String) {
        guard let certificateURL = certificateURL else {
            preconditionFailure()
        }
        
        Task {
            do {
                challenge.resume(with: .useCredential(try .certificate(at: certificateURL, password: password)))
            } catch {
                // This is required to prevent an "already presenting" error.
                try? await Task.sleep(nanoseconds: 100_000)
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
    init(challenge: QueuedNetworkChallenge) {
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
    @MainActor
    @ViewBuilder
    func promptBrowseCertificate(
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
    @MainActor
    @ViewBuilder
    func certificateFilePicker(
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
    @MainActor
    @ViewBuilder
    func passwordSheet(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        sheet(isPresented: isPresented) {
            EnterPasswordView() { password in
                viewModel.proceed(withPassword: password)
            } onCancel: {
                viewModel.cancel()
            }
            .edgesIgnoringSafeArea(.bottom)
            .interactiveDismissDisabled()
        }
    }
}

private extension View {
    /// Displays an alert to notify that there was an error importing the certificate.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor
    @ViewBuilder
    func alertCertificateImportError(
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
            Text("The certificate file or password was invalid.")
        }
    }
}

/// A view that allows the user to enter a password.
struct EnterPasswordView: View {
    @Environment(\.dismiss) var dismissAction
    
    /// The password that the user entered.
    @State var password: String = ""
    
    /// The action to call once the user has completed entering the password.
    var onContinue: (String) -> Void
    
    /// The action to call if the user cancels.
    var onCancel: () -> Void
    
    /// A Boolean value indicating whether the password field has focus.
    @FocusState var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        Text("Please enter a password for the chosen certificate.")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    SecureField("Password", text: $password)
                        .focused($isPasswordFocused)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit {
                            dismissAction()
                            onContinue(password)
                        }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Section {
                    okButton
                }
            }
            .navigationTitle("Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAction()
                        onCancel()
                    }
                }
            }
            .onAppear {
                // Workaround for Apple bug - FB9676178.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isPasswordFocused = true
                }
            }
        }
    }
    
    /// The "OK" button.
    private var okButton: some View {
        Button(action: {
            dismissAction()
            onContinue(password)
        }, label: {
            Text("OK")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        })
        .disabled(password.isEmpty)
        .listRowBackground(!password.isEmpty ? Color.accentColor : Color.gray)
    }
}
