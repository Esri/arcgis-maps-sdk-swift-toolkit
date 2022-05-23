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

struct TrustHostViewModifier: ViewModifier {
    init(challenge: QueuedURLChallenge) {
        self.challenge = challenge
    }
    
    let challenge: QueuedURLChallenge
    
    var host: String {
        challenge.urlChallenge.protectionSpace.host
    }
    
    func body(content: Content) -> some View {
        content
            .alert("Certificate Trust Warning", isPresented: .constant(true), presenting: challenge) { _ in
                Button("Dangerous: Allow Connection", role: .destructive) {
                    challenge.resume(with: .trustHost)
                }
                Button("Cancel", role: .cancel) {
                    challenge.cancel()
                }
            } message: { _ in
                Text("The certificate provided by '\(host)' is not signed by a trusted authority.")
            }
    }
}
