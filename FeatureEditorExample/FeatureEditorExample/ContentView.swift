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

import ArcGISToolkit
import SwiftUI

/// The top-level view for the example app.
struct ContentView: View {
    var body: some View {
        // Adds the feature editor component to the view hierarchy. This is
        // needed for the `MapView.featureEditor(_:)` modifier to work and has
        // to be placed above any navigation views.
        FeatureEditorContainer {
            // This NavigationStack is used to simulate the structure of a
            // real-world application.
            NavigationStack {
                NavigationLink("Open Map View") {
                    ExampleMapView()
                        .navigationTitle("Map View")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .buttonStyle(.borderedProminent)
                .navigationTitle("Feature Editor Example")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
