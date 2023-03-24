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
    enum Scenario: CaseIterable {
        case map
        case sceneWithCamera
        case sceneWithCameraController
        
        /// A human-readable label for the scenario.
        var label: String {
            switch self {
            case .map: return "Map"
            case .sceneWithCamera: return "Scene with camera"
            case .sceneWithCameraController: return "Scene with camera controller"
            }
        }
    }
    
    /// The active scenario.
    @State private var scenario = Scenario.map
    
    var body: some View {
        VStack {
            switch scenario {
            case.map:
                MapWithViewpoint()
            case .sceneWithCamera:
                SceneWithCamera()
            case .sceneWithCameraController:
                SceneWithCameraController()
            }
            Picker("Scenario", selection: $scenario) {
                ForEach(Scenario.allCases, id: \.self) { scen in
                    Text(scen.label)
                }
            }
        }
    }
}

/// An example demonstrating how to use a compass with a map view.
struct MapWithViewpoint: View {
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    /// Allows for communication between the Compass and MapView or SceneView.
    @State private var viewpoint: Viewpoint? = Viewpoint(
        center: .esriRedlands,
        scale: 10_000,
        rotation: -45
    )
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: dataModel.map, viewpoint: viewpoint)
                .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
                .overlay(alignment: .topTrailing) {
                    Compass(viewpoint: $viewpoint)
                    // Optionally provide a different size for the compass.
                    //    .compassSize(size: T##CGFloat)
                        .padding()
                        .onTapGesture {
                            Task {
                                try? await mapViewProxy.setViewpointRotation(0)
                            }
                        }
                }
        }
    }
}

/// An example demonstrating how to use a compass with a scene view and camera.
struct SceneWithCamera: View {
    /// The camera used by the scene view.
    @State private var camera: Camera? = Camera(
        lookingAt: .esriRedlands,
        distance: 1_000,
        heading: 45,
        pitch: 45,
        roll: .zero
    )
    
    /// The data model containing the `Scene` displayed in the `SceneView`.
    @StateObject private var dataModel = SceneDataModel(
        scene: Scene(basemapStyle: .arcGISImagery)
    )
    
    /// The current heading as reported by the scene view.
    var heading: Binding<Double> {
        Binding {
            if let camera {
                return camera.heading
            } else {
                return .zero
            }
        } set: { _ in
        }
    }
    
    var body: some View {
        SceneViewReader { sceneViewProxy in
            SceneView(scene: dataModel.scene, camera: $camera)
                .overlay(alignment: .topTrailing) {
                    Compass(viewpointRotation: heading)
                        .padding()
                        .onTapGesture {
                            if let camera {
                                let newCamera = Camera(
                                    location: camera.location,
                                    heading: .zero,
                                    pitch: camera.pitch,
                                    roll: camera.roll
                                )
                                Task {
                                    try? await sceneViewProxy.setViewpointCamera(
                                        newCamera,
                                        duration: 0.3
                                    )
                                }
                            }
                        }
                }
        }
    }
}

/// An example demonstrating how to use a compass with a scene view and camera controller.
struct SceneWithCameraController: View {
    /// The data model containing the `Scene` displayed in the `SceneView`.
    @StateObject private var dataModel = SceneDataModel(
        scene: Scene(basemapStyle: .arcGISImagery)
    )
    
    /// The current heading as reported by the scene view.
    @State private var heading: Double = .zero
    
    /// The orbit location camera controller used by the scene view.
    private let cameraController = OrbitLocationCameraController(
        target: .esriRedlands,
        distance: 10_000
    )
    
    var body: some View {
        SceneView(scene: dataModel.scene, cameraController: cameraController)
            .onCameraChanged { newCamera in
                heading = newCamera.heading.rounded()
            }
            .overlay(alignment: .topTrailing) {
                Compass(viewpointRotation: $heading)
                    .padding()
                    .onTapGesture {
                        Task {
                            try? await cameraController.moveCamera(
                                distanceDelta: .zero,
                                headingDelta: heading > 180 ? 360 - heading : -heading,
                                pitchDelta: .zero,
                                duration: 0.3
                            )
                        }
                    }
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
