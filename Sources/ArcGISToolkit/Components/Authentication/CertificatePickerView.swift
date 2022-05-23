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

@MainActor final class CertificatePickerViewModel: ObservableObject {
    let challengingHost: String
    let challenge: QueuedURLChallenge
    
    @Published var certificateURL: URL?
    @Published var password: String = ""
    
    init(challenge: QueuedURLChallenge) {
        self.challenge = challenge
        challengingHost = challenge.urlChallenge.protectionSpace.host
    }
    
    func signIn() {
        guard let certificateURL = certificateURL else {
            preconditionFailure()
        }
        
        challenge.resume(with: .certificate(url: certificateURL, passsword: password))
    }
    
    func cancel() {
        challenge.cancel()
    }
}

struct CertificatePickerView: View {
    @ObservedObject var viewModel: CertificatePickerViewModel
    
    @State var showPrompt: Bool = true
    @State var showPicker: Bool = false
    @State var showPassword: Bool = false
    
    var body: some View {
        InvisibleView()
            .promptBrowseCertificateView(
                isPresented: $showPrompt,
                host: viewModel.challengingHost,
                onContinue: {
                    showPicker = true
                }, onCancel: {
                    viewModel.cancel()
                })
            .sheet(isPresented: $showPicker) {
                DocumentPickerView(contentTypes: [.pfx]) {
                    viewModel.certificateURL = $0
                    showPassword = true
                } onCancel: {
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showPassword) {
                EnterPasswordView(password: $viewModel.password) {
                    viewModel.signIn()
                } onCancel: {
                    viewModel.cancel()
                }
                .edgesIgnoringSafeArea(.bottom)
                .interactiveDismissDisabled()
            }
    }
}

private extension UTType {
    static let pfx = UTType(filenameExtension: "pfx")!
}

private extension View {
    @MainActor
    @ViewBuilder
    func promptBrowseCertificateView(
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

struct EnterPasswordView1: View {
    @Binding var password: String
    var onContinue: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            Text("Please enter a password for the chosen certificate.")
                .font(.body)
                .padding([.bottom])
                .multilineTextAlignment(.center)
            
            SecureField(text: $password, prompt: Text("Password")) {
                Text("label")
            }
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            
            HStack {
                Button {
                    onContinue()
                } label: {
                    Text("OK")
                        .frame(maxWidth: .infinity)
                    
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button(role: .cancel) {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            
            Spacer()
        }
        .padding()
        .navigationTitle("Certificate Required")
    }
}

struct EnterPasswordView: View {
    @Binding var password: String
    var onContinue: () -> Void
    var onCancel: () -> Void
    @FocusState var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack {
                        //person
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
                        .onSubmit { onContinue() }
                }
                .autocapitalization(.none)
                .disableAutocorrection(true)

                Section {
                    okButton
                }
            }
            .navigationTitle("Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
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
            onContinue()
        }, label: {
            Text("OK")
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.white)
        })
            .disabled(!password.isEmpty)
            .listRowBackground(!password.isEmpty ? Color.accentColor : Color.gray)
    }
}
