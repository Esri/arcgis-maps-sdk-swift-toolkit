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

/// A view for identifying a feature to edit on a map.
struct ExampleMapView: View {
    /// The feature to edit with the feature editor.
    @State private var featureToEdit: ArcGISFeature?
    /// The result of loading the map used by the example. When the operation
    /// succeeds, this will contain a map with features to edit.
    @State private var mapLoadResult: Result<Map, (any Error)>?
    /// The point on the screen where the user tapped.
    @State private var tapPoint: CGPoint?
    
    var body: some View {
        switch mapLoadResult {
        case .success(let map):
            MapViewReader { mapView in
                MapView(map: map)
                    .onSingleTapGesture { screenPoint, _ in
                        guard tapPoint == nil else { return }
                        tapPoint = screenPoint
                    }
                    // Adds the feature editor to the map view. This needs to
                    // be placed inside a `FeatureEditorContainer`.
                    .featureEditor($featureToEdit)
                    .task(id: tapPoint) {
                        // Identifies the feature at the tapped screen point and
                        // uses it to display the feature editor.
                        guard let tapPoint else { return }
                        defer { self.tapPoint = nil }
                        
                        do {
                            let results = try await mapView.identifyLayers(
                                screenPoint: tapPoint,
                                tolerance: 10
                            )
                            let firstFeature = results.first?.geoElements.first as? ArcGISFeature
                            // The identified feature is passed to the feature editor.
                            featureToEdit = firstFeature
                        } catch {
                            print("Identify error:", error)
                        }
                    }
            }
        case .failure(let error):
            ContentUnavailableView {
                Label("Failed to load map", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("Retry") { mapLoadResult = nil }
            }
        case .none:
            ProgressView("Loading map")
                .task {
                    mapLoadResult = await Result { try await makeMap() }
                }
        }
    }
    
    /// Returns a map with the features to edit, created from a Naperville
    /// Electric web map portal item.
    private func makeMap() async throws -> Map {
        let url = URL(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
        let map = Map(url: url)!
        
        // Enables full resolution feature tiling to improve snapping accuracy.
        map.loadSettings.featureTilingMode = .enabledWithFullResolutionWhenSupported
        
        let initialExtent = Envelope(xRange: -9812750 ... -9812387, yRange: 5131332 ... 5131965)
        map.initialViewpoint = Viewpoint(boundingGeometry: initialExtent)
        
        // Note: Never hardcode login information in a production application.
        // This is done solely for the sake of the example.
        let credential = try await TokenCredential.credential(
            for: map.url!,
            username: "viewer01",
            password: "I68VGU^nMurF"
        )
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        try await map.load()
        
        return map
    }
}
