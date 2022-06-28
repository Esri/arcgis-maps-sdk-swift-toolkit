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

public extension View {
    @ViewBuilder
    func authentication(authenticator: Authenticator) -> some View {
        modifier(InvisibleOverlayModifier(authenticator: authenticator))
    }
}

/// This is an intermediate modifier that overlays an always present invisible view.
/// This view is necessary because of SwiftUI behavior that prevent the UI from functioning
/// properly when showing and hiding sheets. The sheets need to be off of a view that is always
/// present.
private struct InvisibleOverlayModifier: ViewModifier {
    @ObservedObject var authenticator: Authenticator
    
    @ViewBuilder
    func body(content: Content) -> some View {
        ZStack {
            content
            Color.clear
                .frame(width: 0, height: 0)
                .modifier(AuthenticationModifier(authenticator: authenticator))
        }
    }
}

private struct AuthenticationModifier: ViewModifier {
    @ObservedObject var authenticator: Authenticator
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let challenge = authenticator.currentChallenge {
            authenticationView(for: challenge, content: content)
        }
        else {
            content
        }
    }
    
    @ViewBuilder
    func authenticationView(for challenge: QueuedChallenge, content: Content) -> some View {
        switch challenge {
        case let challenge as QueuedArcGISChallenge:
            content.modifier(UsernamePasswordViewModifier(challenge: challenge))
        case let challenge as QueuedNetworkChallenge:
            switch challenge.kind {
            case .serverTrust:
                content.modifier(TrustHostViewModifier(challenge: challenge))
            case .certificate:
                content.modifier(CertificatePickerViewModifier(challenge: challenge))
            case .login:
                content.modifier(UsernamePasswordViewModifier(challenge: challenge))
            }
        default:
            fatalError()
        }
    }
}
