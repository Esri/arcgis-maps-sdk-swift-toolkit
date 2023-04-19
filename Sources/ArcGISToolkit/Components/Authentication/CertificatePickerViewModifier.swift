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
    /// The types of certificate error.
    enum CertificateError: Error {
        /// Could not access the certificate file.
        case couldNotAccessCertificateFile
        /// The certificate import error.
        case importError(CertificateImportError)
        // The other error.
        case other(Error)
    }
    
    /// The challenge that requires a certificate to proceed.
    let challenge: NetworkChallengeContinuation
    
    /// The URL of the certificate that the user chose.
    var certificateURL: URL?
    
    /// A Boolean value indicating whether to show the prompt.
    @Published var showPrompt = true
    
    /// A Boolean value indicating whether to show the certificate file picker.
    @Published var showPicker = false
    
    /// A Boolean value indicating whether to show the password field view.
    @Published var showPassword = false
    
    /// A Boolean value indicating whether to display the error.
    @Published var showCertificateError = false
    
    /// The certificate error that occurred.
    var certificateError: CertificateError?
    
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
    /// - Parameter password: The password for the certificate.
    func proceed(withPassword password: String) {
        guard let certificateURL = certificateURL else {
            preconditionFailure()
        }
        
        Task.detached {
            do {
                if certificateURL.startAccessingSecurityScopedResource() {
                    defer { certificateURL.stopAccessingSecurityScopedResource() }
                    let credential = try NetworkCredential.certificate(at: certificateURL, password: password)
                    await self.challenge.resume(with: .continueWithCredential(credential))
                } else {
                    await self.showCertificateError(.couldNotAccessCertificateFile)
                }
            } catch(let certificateImportError as CertificateImportError) {
                await self.showCertificateError(.importError(certificateImportError))
            } catch {
                await self.showCertificateError(.other(error))
            }
        }
    }
    
    /// Cancels the challenge.
    func cancel() {
        challenge.resume(with: .cancel)
    }

    private func showCertificateError(_ error: CertificateError) async {
        // This is required to prevent an "already presenting" error.
        try? await Task.sleep(nanoseconds: 100_000)
        certificateError = error
        showCertificateError = true
    }
}

extension CertificateImportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return String(localized: "The certificate file was invalid.", bundle: .module)
        case .invalidPassword:
            return String(localized: "The password was invalid.", bundle: .module)
        default:
            return SecCopyErrorMessageString(rawValue, nil) as String? ?? String(
                localized: "The certificate file or password was invalid.",
                bundle: .module
            )
        }
    }
}

extension CertificatePickerViewModel.CertificateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .couldNotAccessCertificateFile:
            return String(localized: "Could not access the certificate file.", bundle: .module)
        case .importError(let error):
            return error.localizedDescription
        case .other(let error):
            return error.localizedDescription
        }
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
            .credentialInput(
                fields: .password,
                isPresented: $viewModel.showPassword,
                message: "Please enter a password for the chosen certificate.",
                title: "Password Required",
                cancelAction: .init(
                    title: "Cancel",
                    handler: { _, _ in
                        viewModel.cancel()
                    }
                ),
                continueAction: .init(
                    title: "OK",
                    handler: { _, password in
                        viewModel.proceed(withPassword: password)
                    }
                )
            )
            .alertCertificateError(
                isPresented: $viewModel.showCertificateError,
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
    /// Displays an alert to notify that there was an error importing the certificate.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func alertCertificateError(
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
            Text(
                viewModel.certificateError?.localizedDescription ?? String(
                    localized: "The certificate file or password was invalid.",
                    bundle: .module
                 )
            )
        }
    }
}
