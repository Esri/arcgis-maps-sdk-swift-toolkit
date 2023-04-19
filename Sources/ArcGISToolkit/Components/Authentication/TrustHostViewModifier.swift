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

/// Prompts the user when encountering an untrusted host.
struct TrustHostViewModifier: ViewModifier {
    /// Creates a `TrustHostViewModifier`.
    /// - Parameter challenge: The network authentication challenge for the untrusted host.
    /// - Precondition: `challenge.kind` is equal to `serverTrust`.
    init(challenge: NetworkChallengeContinuation) {
        precondition(challenge.kind == .serverTrust)
        self.challenge = challenge
    }
    
    /// The network authentication challenge for the untrusted host.
    let challenge: NetworkChallengeContinuation
    
    // Even though we will present it right away we need to use a state variable for this.
    // Using a constant has 2 issues. One, it won't animate. Two, when challenging for multiple
    // endpoints at a time, and the challenges stack up, you can end up with a "already presenting"
    // error.
    @State var isPresented: Bool = false
    
    func body(content: Content) -> some View {
        content
            .task {
                // Present the alert right away. This makes it animated.
                isPresented = true
            }
            .alert("Certificate Trust Warning", isPresented: $isPresented, presenting: challenge) { _ in
                Button("Dangerous: Allow Connection", role: .destructive) {
                    challenge.resume(with: .continueWithCredential(.serverTrust))
                }
                Button("Cancel", role: .cancel) {
                    challenge.resume(with: .cancel)
                }
            } message: { _ in
                Text("The certificate provided by '\(challenge.host)' is not signed by a trusted authority.")
            }
    }
}
