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

@MainActor protocol TrustHostViewModel: ObservableObject {
    var challengingHost: String { get }
    
    func allowConnection()
    func cancel()
}

final class TrustHostChallengeViewModel: TrustHostViewModel {
    init(challenge: QueuedURLChallenge) {
        self.challenge = challenge
    }
    
    let challenge: QueuedURLChallenge
    
    var challengingHost: String {
        challenge.urlChallenge.protectionSpace.host
    }
    
    func allowConnection() {
        challenge.resume(with: .trustHost)
    }
    
    func cancel() {
        challenge.cancel()
    }
}

final class MockTrustHostViewModel: TrustHostViewModel {
    let challengingHost: String
    init(challengingHost: String) {
        self.challengingHost = challengingHost
    }
    func allowConnection() {}
    func cancel() {}
}

struct TrustHostView<ViewModel: TrustHostViewModel>: View {
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject private var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Text("Certificate Trust Warning")
                .font(.title)
                .padding([.bottom])
                .multilineTextAlignment(.center)
            
            Text("The certificate provided by '\(viewModel.challengingHost)' is not signed by a trusted authority.")
                .font(.body)
                .padding([.bottom])
            
            Button(role: .cancel) {
                viewModel.cancel()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Button(role: .destructive) {
                viewModel.allowConnection()
            } label: {
                Text("Dangerous: Allow Connection")
                    .frame(maxWidth: .infinity)
                
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
    }
}

struct TrustHostView_Previews: PreviewProvider {
    static var previews: some View {
        TrustHostView(viewModel: MockTrustHostViewModel(challengingHost: "arcgis.com"))
    }
}
