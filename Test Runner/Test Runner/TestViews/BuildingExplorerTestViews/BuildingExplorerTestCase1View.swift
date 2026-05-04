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

struct BuildingExplorerTestCase1View: View {
    @Bindable private var viewModel = BuildingExplorerTestViewModel()
    
    @State private var layerIsVisible = false
    
    var body: some View {
        LocalSceneView(scene: viewModel.scene)
            .overlay(alignment: .top) {
                Text(verbatim: "Layer is visible: \(layerIsVisible)")
                    .banner()
            }
            .sheet(isPresented: $viewModel.explorerIsVisible) {
                BuildingExplorer(
                    scene: viewModel.scene,
                    items: $viewModel.items,
                    selection: $viewModel.selection
                )
            }
            .task(id: viewModel.selection) {
                if let selection = viewModel.selection {
                    for await isVisible in selection.layer.$isVisible {
                        self.layerIsVisible = isVisible
                    }
                }
            }
    }
}
