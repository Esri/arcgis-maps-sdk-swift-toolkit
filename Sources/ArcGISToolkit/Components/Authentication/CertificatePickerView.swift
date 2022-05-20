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

@MainActor protocol CertificatePickerViewModelProtocol: ObservableObject {
    var challengingHost: String { get }
    
    var certificateURL: URL? { get set }
    
    func signIn()
    func cancel()
}

final class CertificatePickerViewModel: CertificatePickerViewModelProtocol {
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
    var body: some View {
        VStack {
            Text("Choose a certificate for host")
            DocumentPickerView(contentTypes: [.image])
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
