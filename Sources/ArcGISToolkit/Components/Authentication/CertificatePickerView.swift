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
    enum Step {
        case browsePrompt
        case documentPicker
        case enterPassword
    }
    
    @ObservedObject var viewModel: CertificatePickerViewModel
    @State var step: Step = .browsePrompt
    
    @State var showPicker: Bool = false
    
    var body: some View {
        Group {
            switch step {
            case .browsePrompt:
                PromptBrowseCertificateView(host: viewModel.challengingHost) {
                    viewModel.cancel()
                } onContinue: {
                    step = .documentPicker
                    showPicker = true
                }
            case .documentPicker:
                Text("picker")
//                DocumentPickerView(contentTypes: [.pfx]) {
//                    print("-- here!!! \($0)")
//                    viewModel.certificateURL = $0
//                    step = .enterYPassword
//                } onCancel: {
//                    viewModel.cancel()
//                }
            case .enterPassword:
                EnterPasswordView(password: $viewModel.password) {
                    viewModel.cancel()
                } onContinue: {
                    viewModel.signIn()
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPickerView(contentTypes: [.pfx]) {
                viewModel.certificateURL = $0
                step = .enterPassword
            } onCancel: {
                viewModel.cancel()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .interactiveDismissDisabled()
    }
}

private extension UTType {
    static let pfx = UTType(filenameExtension: "pfx")!
}

struct PromptBrowseCertificateView: View {
    var host: String
    var onCancel: () -> Void
    var onContinue: () -> Void
    
    var body: some View {
        VStack {
            Text("A certificate is required to access content on \(host)")
                .font(.body)
                .padding([.bottom])
                .multilineTextAlignment(.center)
            
            Button(role: .cancel) {
                onCancel()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button {
                onContinue()
            } label: {
                Text("Browse for a certificate")
                    .frame(maxWidth: .infinity)
                
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Certificate Required")
    }
}

struct EnterPasswordView: View {
    @Binding var password: String
    var onCancel: () -> Void
    var onContinue: () -> Void
    
    
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

