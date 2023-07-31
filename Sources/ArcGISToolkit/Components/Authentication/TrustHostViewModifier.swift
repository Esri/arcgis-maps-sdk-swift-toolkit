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
    
    var title: some View {
        Text(
            "Certificate Trust Warning",
            bundle: .toolkitModule,
            comment: "A label indicating that the remote host's certificate is not trusted."
        )
        .font(.title)
        .multilineTextAlignment(.center)
    }
    
    var message: some View {
        Text(
            "Dangerous: The certificate provided by '\(challenge.host)' is not signed by a trusted authority.",
            bundle: .toolkitModule,
            comment: "A warning that the host service (challenge.host) is providing a potentially unsafe certificate."
        )
        .multilineTextAlignment(.center)
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                // Present the sheet right away.
                // Setting it after initialization allows it to animate.
                // However, we use .task because this needs to happen after a slight delay or
                // it doesn't show.
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                VStack(alignment: .center) {
                    title
                        .padding(.vertical)
                    message
                        .padding(.bottom)
                    HStack {
                        Spacer()
                        Button(role: .cancel) {
                            isPresented = false
                            challenge.resume(with: .cancel)
                        } label: {
                            Text("Cancel", bundle: .toolkitModule)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button(role: .destructive) {
                            isPresented = false
                            challenge.resume(with: .continueWithCredential(.serverTrust))
                        } label: {
                            Text(
                                "Allow",
                                bundle: .toolkitModule,
                                comment: "A button indicating the user accepts a potentially dangerous action."
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    Spacer()
                }
                .padding()
                .mediumPresentationDetents()
            }
    }
}
