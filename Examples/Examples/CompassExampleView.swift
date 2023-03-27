// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

/// An example demonstrating how to use a compass in three different environments.
struct CompassExampleView: View {
    /// A scenario represents a type of environment a compass may be used in.
    enum Scenario: String {
        case map
        case scene
    }
    
    /// The active scenario.
    @State private var scenario = Scenario.map
    
    var body: some View {
        Group {
            switch scenario {
            case .map:
                MapWithViewpoint()
            case .scene:
                SceneWithCameraController()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(scenario.rawValue.capitalized) {
                    Button {
                        scenario = .map
                    } label: {
                        Label("Map", systemImage: "map.fill")
                    }
                    
                    Button {
                        scenario = .scene
                    } label: {
                        Label("Scene", systemImage: "globe.americas.fill")
                    }
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }
}

/// An example demonstrating how to use a compass with a map view.
struct MapWithViewpoint: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    /// Allows for communication between the Compass and MapView or SceneView.
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: .esriRedlands,
        scale: 10_000,
        rotation: -45
    )
    
    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(alignment: .topTrailing) {
                Compass(viewpoint: $viewpoint)
                    .padding()
            }
    }
}

/// An example demonstrating how to use a compass with a scene view and camera controller.
struct SceneWithCameraController: View {
    /// The data model containing the `Scene` displayed in the `SceneView`.
    @State private var scene = Scene(basemapStyle: .arcGISImagery)
    
    /// The current heading as reported by the scene view.
    @State private var heading = Double.zero
    
    /// The orbit location camera controller used by the scene view.
    private let cameraController = OrbitLocationCameraController(
        target: .esriRedlands,
        distance: 10_000
    )
    
    var body: some View {
        SceneView(scene: scene, cameraController: cameraController)
            .onCameraChanged { newCamera in
                heading = newCamera.heading.rounded()
            }
            .overlay(alignment: .topTrailing) {
                Compass(
                    viewpointRotation: $heading,
                    action: {
                        _ = try? await cameraController.moveCamera(
                            distanceDelta: .zero,
                            headingDelta: heading > 180 ? 360 - heading : -heading,
                            pitchDelta: .zero,
                            duration: 0.3
                        )
                    }
                )
                .padding()
            }
    }
}

private extension Point {
    static var esriRedlands: Point {
        .init(
            x: -117.19494,
            y: 34.05723,
            spatialReference: .wgs84
        )
    }
}
