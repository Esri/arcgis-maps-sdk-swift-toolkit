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
import CoreLocation
import SwiftUI

/// An example view that demonstrates how to implement a custom VPS provider
/// for the `WorldScaleSceneView`.
struct CustomVPSProviderExampleView: View {
    /// A scene configured with imagery basemap and elevation.
    @State private var scene: ArcGIS.Scene = {
        // Creates an elevation source from Terrain3D REST service.
        let elevationServiceURL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
        let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
        let surface = Surface()
        surface.addElevationSource(elevationSource)
        surface.backgroundGrid.isVisible = false
        surface.navigationConstraint = .unconstrained
        let scene = Scene(basemapStyle: .arcGISImagery)
        scene.baseSurface = surface
        scene.baseSurface.opacity = 0
        return scene
    }()
    /// The world-tracking provider used by this example.
    @State private var provider: CustomWorldTracking?
    /// The error that occurred while creating the world-tracking provider, if
    /// any.
    @State private var providerError: Error?
    /// A Boolean value indicating whether to show streetscape geometry, which
    /// includes buildings and other structures.
    @State private var streetscapeGeometryEnabled = true
    /// The custom VPS provider Google API key.
    private let apiKey = "<#Google API Key#>"
    
    var body: some View {
        NavigationStack {
            Group {
                if let provider {
                    WorldScaleSceneView(provider: provider) { context in
                        CustomWorldTrackingCameraFeedView(context: context)
                            .streetscapeGeometryEnabled(streetscapeGeometryEnabled)
                    } sceneView: { _ in
                        SceneView(scene: scene)
                    }
                    .calibrationViewHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Toggle("Show Buildings", isOn: $streetscapeGeometryEnabled)
                        }
                    }
                } else if let providerError {
                    ContentUnavailableView(
                        "Provider Unavailable",
                        image: "exclamationmark.triangle",
                        description: Text(providerError.localizedDescription)
                    )
                } else {
                    ProgressView()
                        .onAppear {
                            do {
                                provider = try CustomWorldTracking(apiKey: apiKey)
                            } catch {
                                providerError = error
                            }
                        }
                }
            }
            .navigationTitle("Custom VPS Provider Example")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
