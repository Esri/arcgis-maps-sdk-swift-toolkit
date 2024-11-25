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
import SwiftUI

/// The view that is displayed after successfully signing in.
struct HomeView: View {
    /// The portal that the user is signed in to.
    @State private var portal: Portal?
    
    /// A Boolean value indicating whether the profile view should be presented.
    @State private var showProfile = false
    
    var body: some View {
        if let portal = portal {
            NavigationSplitView {
                WebMapsView(portal: portal)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showProfile = true
                            } label: {
                                Image(systemName: "person.circle")
                            }
                            .sheet(isPresented: $showProfile) {
                                ProfileView(portal: portal) {
                                    self.portal = nil
                                }
                            }
                        }
                    }
            } detail: {
                Text("No Webmap Selected")
            }
        } else {
            SignInView(portal: $portal)
        }
    }
}
