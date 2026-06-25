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
    /// The geometry editor that the feature editor will use to edit geometries
    /// on the `MapView`.
    @State private var geometryEditor = GeometryEditor()
    /// The map with the features to edit, created from a Naperville Electric web map portal item.
    @State private var map: Map = {
        let url = URL(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
        let map = Map(url: url)!
        
        // Enables full resolution feature tiling to improve snapping accuracy.
        map.loadSettings.featureTilingMode = .enabledWithFullResolutionWhenSupported
        
        let initialExtent = Envelope(xRange: -9815340 ... -9815040, yRange: 5129550 ... 5130070)
        map.initialViewpoint = Viewpoint(boundingGeometry: initialExtent)
        
        return map
    }()
    /// The point on the screen where the user tapped.
    @State private var tapPoint: CGPoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .geometryEditor(geometryEditor)
                .onSingleTapGesture { screenPoint, _ in
                    guard tapPoint == nil else { return }
                    tapPoint = screenPoint
                }
                .task(id: tapPoint) {
                    // Identifies the feature at the tapped screen point and
                    // uses it to display the feature editor.
                    guard let tapPoint else { return }
                    defer { self.tapPoint = nil }
                    
                    do {
                        let results = try await mapViewProxy.identifyLayers(
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
        .overlay(alignment: .topTrailing) {
            // The feature editor needs to be placed below the
            // `featureEditorInspector` modifier in the view hierarchy.
            FeatureEditor(
                $featureToEdit,
                geometryEditor: geometryEditor
            )
            .padding()
        }
        .task {
            do {
                try await setUp()
            } catch {
                print("Setup error:", error)
            }
        }
    }
    
    /// Sets up the map and snap settings.
    private func setUp() async throws {
        // Note: Never hardcode login information in a production application.
        // This is done solely for the sake of the example.
        let credential = try await TokenCredential.credential(
            for: map.url!,
            username: "viewer01",
            password: "I68VGU^nMurF"
        )
        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
        try await map.retryLoad()
        
        // Enables the geometry editor's snap settings and sources.
        let snapSettings = geometryEditor.snapSettings
        snapSettings.snapsToGeometryGuides = true
        
        await map.operationalLayers.load()
        try snapSettings.syncSourceSettings()
        
        for sourceSetting in snapSettings.sourceSettings {
            sourceSetting.isEnabled = true
        }
    }
}
