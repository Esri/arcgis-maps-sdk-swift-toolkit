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

@MainActor
final private class CertificatePickerViewModel: ObservableObject {
    let challengingHost: String
    let challenge: QueuedNetworkChallenge
    
    @Published private(set) var certificateURL: URL?
    @Published var showPrompt = true
    @Published var showPicker = false
    @Published var showPassword = false
    @Published var showCertificateImportError = false
    
    init(challenge: QueuedNetworkChallenge) {
        self.challenge = challenge
        challengingHost = challenge.networkChallenge.host
    }
    
    func proceedFromPrompt() {
        showPicker = true
    }
    
    func proceed(withCertificateURL url: URL) {
        certificateURL = url
        showPassword = true
    }
    
    func proceed(withPassword password: String) {
        guard let certificateURL = certificateURL else {
            preconditionFailure()
        }
        
        Task {
            do {
                challenge.resume(with: .useCredential(try .certificate(at: certificateURL, password: password)))
            } catch {
                // This is required to prevent an "already presenting" error.
                await Task.yield()
                showCertificateImportError = true
            }
        }
    }
    
    func cancel() {
        challenge.resume(with: .cancelAuthenticationChallenge)
    }
}

struct CertificatePickerViewModifier: ViewModifier {
    init(challenge: QueuedNetworkChallenge) {
        viewModel = CertificatePickerViewModel(challenge: challenge)
    }
    
    @ObservedObject private var viewModel: CertificatePickerViewModel

    func body(content: Content) -> some View {
        content
            .promptBrowseCertificate(
                isPresented: $viewModel.showPrompt,
                host: viewModel.challengingHost,
                onContinue: {
                    viewModel.proceedFromPrompt()
                }, onCancel: {
                    viewModel.cancel()
                }
            )
            .sheet(isPresented: $viewModel.showPicker) {
                DocumentPickerView(contentTypes: [.pfx]) {
                    viewModel.proceed(withCertificateURL: $0)
                } onCancel: {
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $viewModel.showPassword) {
                EnterPasswordView() { password in
                    viewModel.proceed(withPassword: password)
                } onCancel: {
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
            .alert("Error importing certificate", isPresented: $viewModel.showCertificateImportError) {
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

private extension UTType {
    static let pfx = UTType(filenameExtension: "pfx")!
}

private extension View {
    @ViewBuilder
    func promptBrowseCertificate(
        isPresented: Binding<Bool>,
        host: String,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        alert("Certificate Required", isPresented: isPresented, presenting: host) { _ in
            Button("Browse For Certificate") {
                onContinue()
            }
            Button("Cancel", role: .cancel) {
                onCancel()
            }
        } message: { _ in
            Text("A certificate is required to access content on \(host).")
        }
    }
}

struct EnterPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State var password: String = ""
    var onContinue: (String) -> Void
    var onCancel: () -> Void
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
                            dismiss()
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
                        dismiss()
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
    
    private var okButton: some View {
        Button(action: {
            dismiss()
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
