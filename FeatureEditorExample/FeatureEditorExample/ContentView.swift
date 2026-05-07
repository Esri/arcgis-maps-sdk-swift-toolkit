// Copyright 2025 Esri
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

struct ContentView: View {
    @State private var featureEditorModel = FeatureEditorModel()
    @State private var isShowingMapView = true
    
    var body: some View {
        NavigationStack {
            Button("Open Example") {
                isShowingMapView = true
            }
            .navigationDestination(isPresented: $isShowingMapView) {
                ExampleMapView()
            }
        }
        .environment(featureEditorModel)
        .featureEditor(
            item: $featureEditorModel.featureEditorItem,
            geometryEditor: featureEditorModel.geometryEditor,
            viewpoint: $featureEditorModel.viewpoint,
            contentInsets: $featureEditorModel.contentInsets
        )
    }
}

@Observable
final class FeatureEditorModel {
    var featureEditorItem: (any FeatureEditorItem)?
    let geometryEditor = GeometryEditor()
    var viewpoint: Viewpoint?
    var contentInsets: EdgeInsets?
}
