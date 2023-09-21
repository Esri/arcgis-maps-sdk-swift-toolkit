// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct TableTopExampleView: View {
    @State private var scene: ArcGIS.Scene = {
        let scene = Scene(item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
        )
        )
        scene.baseSurface.navigationConstraint = .unconstrained
        scene.baseSurface.opacity = 0
        return scene
    }()
    
    private let anchorPoint = Point(x: 4.4777, y: 51.9244, spatialReference: .wgs84)
    
    var body: some View {
        TableTopSceneView(
            anchorPoint: anchorPoint,
            translationFactor: 1_000,
            clippingDistance: 100
        ) { proxy in
            SceneView(scene: scene)
                .onSingleTapGesture { screen, _ in
                    print("Identifying...")
                    Task.detached {
                        let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                    }
                }
        }
    }
}
