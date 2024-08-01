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
import SwiftUI

/// A view that displays the profile of a user.
@MainActor
struct ProfileView: View {
    /// The portal that the user is signed in to.
    let portal: Portal
    
    /// A Boolean indicating whether the user is signing out.
    @State private var isSigningOut = false
    
    /// The closure to call once the user has signed out.
    var signOutAction: () -> Void
    
    var body: some View {
        VStack {
            if let user = portal.user {
                UserView(user: user).padding()
            }
            Spacer()
            signOutButton
        }
        .padding()
    }
    
    var signOutButton: some View {
        Button(role: .destructive) {
            signOut()
        } label: {
            if isSigningOut {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .disabled(isSigningOut)
    }
    
    /// Signs out from the portal and clears the credential stores.
    func signOut() {
        isSigningOut = true
        Task {
            await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
            await ArcGISEnvironment.authenticationManager.clearCredentialStores()
            isSigningOut = false
            signOutAction()
        }
    }
}
