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
import ArcGIS
import ArcGISToolkit

/// A view that allows the user to sign in to a portal.
struct SigninView: View {
    /// The authenticator which has been passed from the app through the environment.
    @EnvironmentObject var authenticator: Authenticator
    
    /// The error that occurred during an attempt to sign in.
    @State var error: Error?
    
    /// A Boolean value indicating if the user is currently signing in.
    @State var isSigningIn: Bool = false
    
    /// The portal that the user successfully signed in to.
    @Binding var portal: Portal?
    
    var body: some View {
        VStack {
            Spacer()
            if isSigningIn {
                ProgressView()
            } else {
                Text(URL.portal.host!)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                signInButton
            }
            Spacer()
            if let error = error, !error.isChallengeCancellationError {
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    var signInButton: some View {
        Button {
            signIn()
        } label: {
            Text("Sign in")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(isSigningIn || portal != nil)
    }
    
    /// Attempts to sign into a portal.
    func signIn() {
        isSigningIn = true
        error = nil
        Task {
            do {
                let portal = Portal(url: .portal, isLoginRequired: true)
                try await portal.load()
                self.portal = portal
            } catch {
                self.error = error
            }
            isSigningIn = false
        }
    }
}

private extension Error {
    /// Returns a Boolean value indicating whether the error is the result of cancelling an
    /// authentication challenge.
    var isChallengeCancellationError: Bool {
        switch self {
        case let error as ArcGISAuthenticationChallenge.Error:
            switch error {
            case .userCancelled:
                return true
            default:
                return false
            }
        case let error as NSError:
            return error.domain == NSURLErrorDomain && error.code == -999
        default:
            return false
        }
    }
}
