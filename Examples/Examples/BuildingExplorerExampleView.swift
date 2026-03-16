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
    @State private var scene = Scene(url: URL(string: "https://www.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44")!)!
    @State private var explorerIsVisible = false
    @State private var items: [BuildingExplorerItem] = []
    @State private var selection: BuildingExplorerItem?
    
    var body: some View {
        LocalSceneViewReader { proxy in
            LocalSceneView(scene: scene)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Building Explorer", systemImage: "building") {
                            explorerIsVisible = true
                        }
                        .popover(isPresented: $explorerIsVisible) {
                            BuildingExplorer(
                                scene: scene,
                                items: $items,
                                selection: $selection,
                                localSceneViewProxy: proxy
                            )
                            .frame(idealWidth: 400, idealHeight: 500)
                            .presentationCompactAdaptation(.popover)
                        }
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
