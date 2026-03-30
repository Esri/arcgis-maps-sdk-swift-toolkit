// Copyright 2026 Esri
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

struct BuildingExplorerExampleView: View {
    /// The scene to be displayed.
    @State private var scene = Scene(url: URL(string: "https://www.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44")!)!
    /// A Boolean indicating if the building explorer is visible.
    @State private var explorerIsVisible = false
    /// The items to show in the building explorer.
    @State private var items: [BuildingExplorerItem] = []
    /// The selected item in the building explorer.
    @State private var selection: BuildingExplorerItem?
    
    var body: some View {
        LocalSceneView(scene: scene)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Building Explorer", systemImage: "building") {
                        explorerIsVisible = true
                    }
                    // Apple Bug #FB22283945. A crash could occur
                    // on Mac Catalyst when presenting a popover
                    // from a toolbar button.
                    .popover(isPresented: $explorerIsVisible) {
                        BuildingExplorer(
                            scene: scene,
                            items: $items,
                            selection: $selection
                        )
                        .frame(idealWidth: 400, idealHeight: 500)
                        .presentationDetents([.medium, .large])
                        .presentationBackgroundInteraction(.enabled)
                        .presentationContentInteraction(.scrolls)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        BuildingExplorerExampleView()
    }
}
