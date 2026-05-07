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

struct BuildingExplorerTestCase2View: View {
    @Bindable private var viewModel = BuildingExplorerTestViewModel()
    
    @State private var fullModelIsVisible = true
    @State private var updateText = false
    
    var body: some View {
        LocalSceneView(scene: viewModel.scene)
            .sheet(isPresented: $viewModel.explorerIsVisible) {
                VStack {
                    Text(verbatim: "Full model is visible: \(fullModelIsVisible)")
                    Button("Update") { updateText = true }
                    BuildingExplorer(
                        scene: viewModel.scene,
                        items: $viewModel.items,
                        selection: $viewModel.selection
                    )
                }
            }
            .task(id: updateText) {
                // Once the button is pressed then
                // we know to update the text.
                if updateText,
                   let selection = viewModel.selection,
                   let fullModelSublayer = selection.layer.sublayers.first(where: { $0.modelName.lowercased() == "fullmodel" }) {
                    fullModelIsVisible = fullModelSublayer.isVisible
                    
                    // Reset Boolean.
                    updateText = false
                }
            }
    }
}
