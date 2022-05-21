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

struct AuthenticationView: View {
    init(challenge: IdentifiableQueuedChallenge) {
        self.challenge = challenge.queuedChallenge
    }

    let challenge: QueuedChallenge
    
    var body: some View {
        switch challenge {
        case let challenge as QueuedArcGISChallenge:
            UsernamePasswordView(viewModel: TokenCredentialViewModel(challenge: challenge))
        case let challenge as QueuedURLChallenge:
            view(forURLChallenge: challenge)
        default:
            fatalError()
        }
    }
    
    @MainActor
    @ViewBuilder
    func view(forURLChallenge challenge: QueuedURLChallenge) -> some View {
        switch challenge.urlChallenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodServerTrust:
            TrustHostView(challenge: challenge)
        case NSURLAuthenticationMethodClientCertificate:
            CertificatePickerView(viewModel: CertificatePickerViewModel(challenge: challenge))
        case NSURLAuthenticationMethodDefault,
            NSURLAuthenticationMethodNTLM,
            NSURLAuthenticationMethodHTMLForm,
            NSURLAuthenticationMethodHTTPBasic,
        NSURLAuthenticationMethodHTTPDigest:
            UsernamePasswordView(viewModel: URLCredentialUsernamePasswordViewModel(challenge: challenge))
        default:
            fatalError()
        }
    }
}

public extension View {
    @MainActor
    @ViewBuilder
    func authentication(authenticator: Authenticator) -> some View {
        modifier(AuthenticationModifier(authenticator: authenticator))
    }
    
//    func authentication(authenticator: Authenticator) -> some View {
//        ZStack {
//            if let challenge = authenticator.currentChallenge {
//                AuthenticationView(challenge: challenge)
//            }
//        }
//    }
//    func authentication(authenticator: Authenticator) -> some View {
//        if let challenge = authenticator.currentChallenge {
//            overlay(AuthenticationView(challenge: challenge))
//        } else {
//            overlay(EmptyView())
//        }
//    }
}

struct AuthenticationModifier: ViewModifier {
    @ObservedObject var authenticator: Authenticator
    
//    func body(content: Content) -> some View {
//        if let challenge = authenticator.currentChallenge {
//            content.overlay(AuthenticationView(challenge: challenge))
//        } else {
//            content
//        }
//    }
    func body(content: Content) -> some View {
        ZStack {
            content
            if let challenge = authenticator.currentChallenge {
                AuthenticationView(challenge: challenge)
            }
        }
    }
}
