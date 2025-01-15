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

import ArcGIS
import Combine
import SwiftUI
import UniformTypeIdentifiers

/// An object that provides the business logic for the workflow of prompting the user for a
/// certificate and a password.
@MainActor final class CertificatePickerViewModel: ObservableObject {
    /// The types of certificate error.
    enum CertificateError: Error {
        /// Failed to access the certificate file.
        case failedToAccessCertificateFile
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
    @Published var showPrompt = false
    
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
    func proceedToPicker() {
        Task {
            // If we don't delay this, then the picker does not animate in.
            // Delay for 0.25 seconds.
            try await Task.sleep(nanoseconds: 250_000_000)
            self.showPicker = true
        }
    }
    
    /// Proceeds to show the user the password form. This should be called after the user selects
    /// a certificate.
    /// - Parameter url: The URL of the certificate that the user chose.
    func proceedToPasswordEntry(forCertificateWithURL url: URL) {
        certificateURL = url
        showPassword = true
    }
    
    /// Attempts to use the certificate and password to respond to the challenge.
    /// - Parameter password: The password for the certificate.
    func proceedToUseCertificate(withPassword password: String) {
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
                    await self.showCertificateError(.failedToAccessCertificateFile)
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
    
    private func showCertificateError(_ error: CertificateError) {
        certificateError = error
        showCertificateError = true
    }
}

extension ArcGIS.CertificateImportError: Foundation.LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return String(
                localized: "The certificate file was invalid.",
                bundle: .toolkitModule,
                comment: "A label indicating the chosen file was invalid."
            )
        case .invalidPassword:
            return String(
                localized: "The password was invalid.",
                bundle: .toolkitModule,
                comment: "A label indicating the given password was invalid."
            )
        default:
            return SecCopyErrorMessageString(rawValue, nil) as String? ?? String(
                localized: "The certificate file or password was invalid.",
                bundle: .toolkitModule,
                comment: "A label indicating the chosen file or given password was invalid."
            )
        }
    }
}

extension CertificatePickerViewModel.CertificateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToAccessCertificateFile:
            return String(
                localized: "Failed to access the certificate file.",
                bundle: .toolkitModule,
                comment: "A label indicating a certificate file was inaccessible."
            )
        case .importError(let error):
            return error.localizedDescription
        case .other(let error):
            return error.localizedDescription
        }
    }
}

/// A view modifier that presents a certificate picker workflow.
@MainActor
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
            .delayedOnAppear {
                // Present the prompt right away.
                // Setting it after initialization allows it to animate.
                // However, this needs to happen after a slight delay or
                // it doesn't show.
                viewModel.showPrompt = true
            }
            .promptBrowseCertificate(
                isPresented: $viewModel.showPrompt,
                viewModel: viewModel
            )
            .certificateFilePicker(
                isPresented: $viewModel.showPicker,
                viewModel: viewModel
            )
            .credentialInput(
                isPresented: $viewModel.showPassword,
                fields: .password,
                message: String(
                    localized: "Please enter a password for the chosen certificate.",
                    bundle: .toolkitModule,
                    comment: "A label requesting the password associated with the chosen certificate."
                ),
                title: String(
                    localized: "Password Required",
                    bundle: .toolkitModule,
                    comment: "A label indicating that a password is required to proceed with an operation."
                ),
                cancelAction: .init(
                    title: String.cancel,
                    handler: { _, _ in
                        viewModel.cancel()
                    }
                ),
                continueAction: .init(
                    title: String(
                        localized: "OK",
                        bundle: .toolkitModule,
                        comment: "A label for button to proceed with an operation."
                    ),
                    handler: { _, password in
                        viewModel.proceedToUseCertificate(withPassword: password)
                    }
                )
            )
            .certificateErrorSheet(
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
        sheet(isPresented: isPresented) {
            VStack(alignment: .center) {
                Text(
                    "Certificate Required",
                    bundle: .toolkitModule,
                    comment: "A label indicating that a certificate is required to proceed."
                )
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.vertical)
                Text(
                    "A certificate is required to access content on \(viewModel.challengingHost).",
                    bundle: .toolkitModule,
                    comment: """
                             An alert message indicating that a certificate is required to access
                             content on a remote host. The variable is the host that prompted the challenge.
                             """
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                HStack {
                    Spacer()
                    Button(role: .cancel) {
                        isPresented.wrappedValue = false
                        viewModel.cancel()
                    } label: {
                        Text(String.cancel)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button(role: .cancel) {
                        isPresented.wrappedValue = false
                        viewModel.proceedToPicker()
                    } label: {
                        Text(
                            "Browse",
                            bundle: .toolkitModule,
                            comment: "A label for a button to open the system file browser."
                        )
                        .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                Spacer()
            }
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .padding()
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
                isPresented.wrappedValue = false
                viewModel.proceedToPasswordEntry(forCertificateWithURL: $0)
            } onCancel: {
                isPresented.wrappedValue = false
                viewModel.cancel()
            }
            .interactiveDismissDisabled()
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

private extension View {
    /// Displays a sheet to notify that there was an error importing the certificate.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - viewModel: The view model associated with the view.
    @MainActor @ViewBuilder func certificateErrorSheet(
        isPresented: Binding<Bool>,
        viewModel: CertificatePickerViewModel
    ) -> some View {
        sheet(isPresented: isPresented) {
            VStack(alignment: .center) {
                Text(
                    "Error importing certificate",
                    bundle: .toolkitModule,
                    comment: """
                             A message indicating that some error occurred while importing a chosen
                             network certificate.
                             """
                )
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.vertical)
                
                Text(
                    viewModel.certificateError?.localizedDescription ?? String(
                        localized: "The certificate file or password was invalid.",
                        bundle: .toolkitModule,
                        comment: "A label indicating the chosen file or given password was invalid."
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                HStack {
                    Spacer()
                    Button(role: .cancel) {
                        isPresented.wrappedValue = false
                        viewModel.cancel()
                    } label: {
                        Text(String.cancel)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                    Button(role: .cancel) {
                        isPresented.wrappedValue = false
                        viewModel.proceedToPicker()
                    } label: {
                        Text(
                            "Try Again",
                            bundle: .toolkitModule,
                            comment: "A label for a button allowing the user to retry an operation."
                        )
                        .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                Spacer()
            }
            .interactiveDismissDisabled()
            .presentationDetents([.medium])
            .padding()
        }
    }
}
