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
    /// Presents user experiences for collecting network authentication credentials from the user.
    /// - Parameter authenticator: The authenticator for which credentials will be prompted.
    @ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View {
        modifier(AuthenticatorOverlayModifier(authenticator: authenticator))
    }
}

/// A view modifier that overlays an always present invisible view for which the
/// authenticator view modifiers can modify.
/// This view is necessary because of SwiftUI behavior that prevent the UI from functioning
/// properly when showing and hiding sheets. The sheets need to be off of a view that is always
/// present.
/// The problem that I was seeing without this is content in lists not updating properly
/// after a sheet was dismissed.
private struct AuthenticatorOverlayModifier: ViewModifier {
    @ObservedObject var authenticator: Authenticator
    
    @ViewBuilder func body(content: Content) -> some View {
        ZStack {
            content
            Color.clear
                .frame(width: 0, height: 0)
                .modifier(AuthenticatorModifier(authenticator: authenticator))
        }
    }
}

/// A view modifier that prompts for credentials.
private struct AuthenticatorModifier: ViewModifier {
    @ObservedObject var authenticator: Authenticator
    
    @ViewBuilder func body(content: Content) -> some View {
        switch authenticator.currentChallenge {
        case let challenge as TokenChallengeContinuation:
            content.modifier(LoginViewModifier(challenge: challenge))
        case let challenge as NetworkChallengeContinuation:
            switch challenge.kind {
            case .serverTrust:
                content.modifier(TrustHostViewModifier(challenge: challenge))
            case .certificate:
                content.modifier(CertificatePickerViewModifier(challenge: challenge))
            case .login:
                content.modifier(LoginViewModifier(challenge: challenge))
            }
        case .none:
            content
        default:
            fatalError("unknown challenge type")
        }
    }
}
