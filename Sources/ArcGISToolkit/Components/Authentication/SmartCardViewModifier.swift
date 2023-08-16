// Copyright 2023 Esri.

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

/// A view modifier that prompts the alerts for smart card.
struct SmartCardViewModifier: ViewModifier {
    /// The authenticator.
    @EnvironmentObject var authenticator: Authenticator
    
    /// The smart card manager.
    @EnvironmentObject var smartCardManager: SmartCardManager
    
    func body(content: Content) -> some View {
        content
            .promptDisconnectedCard(
                isPresented: $smartCardManager.isCardDisconnected,
                authenticator: authenticator
            )
            .promptDifferentCardConnected(
                isPresented: $smartCardManager.isDifferentCardConnected,
                authenticator: authenticator
            )
    }
}

private extension View {
    /// Displays an alert to the user to let them know that the smart card is disconnected.
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to present an alert.
    ///   - authenticator: The authenticator.
    @MainActor @ViewBuilder func promptDisconnectedCard(
        isPresented: Binding<Bool>,
        authenticator: Authenticator
    ) -> some View {
        alert(
            Text("Smart Card Disconnected", bundle: .toolkitModule),
            isPresented: isPresented
        ) {
            Button(role: .cancel) {
                Task {
                    await authenticator.signOutAction()
                }
            } label: {
                Text("Sign Out", bundle: .toolkitModule)
            }
            Button(role: .destructive) {
                print("Continue")
            } label: {
                Text("Continue", bundle: .toolkitModule)
            }
        } message: {
            Text(
                "Connect a smart card and continue or sign out to access a different account.",
                bundle: .toolkitModule
            )
        }
    }
}

private extension View {
    /// Displays a prompt to the user to let them know that the smart card is disconnected.
    /// - Parameters: isPresented: A Boolean value indicating if the view is presented.
    @MainActor @ViewBuilder func promptDifferentCardConnected(
        isPresented: Binding<Bool>,
        authenticator: Authenticator
    ) -> some View {
        alert(
            Text("Different Card Connected", bundle: .toolkitModule),
            isPresented: isPresented
        ) {
            Button(role: .cancel) {
                Task {
                    await authenticator.signOutAction()
                }
            } label: {
                Text("Sign Out", bundle: .toolkitModule)
            }
        } message: {
            Text(
                "You must sign out to access a different account.",
                bundle: .toolkitModule
            )
        }
    }
}

