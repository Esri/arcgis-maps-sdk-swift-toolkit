// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import CryptoKit
import SwiftUI

/// A view that allows the user to sign in to a portal.
struct SignInView: View {
    /// The error that occurred during an attempt to sign in.
    @State private var error: Error?
    
    /// A Boolean value indicating if the user is currently signing in.
    @State private var isSigningIn = false
    
    /// The portal that the user successfully signed in to.
    @Binding var portal: Portal?
    
    /// The last signed in user name.
    /// - If the property is `nil` then there was no previous effective credential.
    /// - If the property is non-nil and empty, then the previously persisted and effective
    /// credential did not have a username.
    /// - If the property is non-nil and non-empty, then it contains the previously used and
    /// persisted username.
    @State private var lastSignedInUser: String?
    
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
        .task {
            guard lastSignedInUser == nil else {
                return
            }
            
            if let arcGISCredential = ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credential(for: .portal) {
                lastSignedInUser = arcGISCredential.username
            } else {
                let networkCredentials = await ArcGISEnvironment.authenticationManager.networkCredentialStore.credentials(forHost: URL.portal.host!)
                if !networkCredentials.isEmpty {
                    lastSignedInUser = networkCredentials.compactMap { credential in
                        switch credential {
                        case .password(let passwordCredential):
                            return passwordCredential.username
                        case .certificate(let certificateCredential):
                            return certificateCredential.identityName
                        case .serverTrust:
                            return nil
                        case .smartCard(let smartCardCredential):
                            return smartCardCredential.identityName
                        @unknown default:
                            fatalError("Unknown NetworkCredential")
                        }
                    }
                    .first
                }
            }
        }
        .padding()
    }
    
    var signInButtonText: String {
        if let lastSignedInUser = lastSignedInUser {
            if lastSignedInUser.isEmpty {
                // Non-nil but empty, can't offer the username.
                return "Sign in again"
            } else {
                // Non-nil and non-empty, show the username in the button text.
                return "Sign in with \(lastSignedInUser)"
            }
        } else {
            // For nil username, then just use default text that implies there was no previous
            // used credential persisted.
            return "Sign in"
        }
    }
    
    var signInButton: some View {
        Button {
            signIn()
        } label: {
            Text(signInButtonText)
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
                let portal = Portal(url: .portal, connection: .authenticated)
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
        case is ArcGISChallengeCancellationError:
            return true
        case let error as NSError:
            return error.domain == NSURLErrorDomain && error.code == -999
        default:
            return false
        }
    }
}
