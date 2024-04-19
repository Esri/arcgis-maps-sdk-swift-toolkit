// Copyright 2023 Esri
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

struct TableTopExampleView: View {
    @State private var scene: ArcGIS.Scene = {
        // Creates a scene layer from buildings REST service.
        let buildingsURL = URL(string: "https://tiles.arcgis.com/tiles/P3ePLMYs2RVChkJx/arcgis/rest/services/DevA_BuildingShells/SceneServer")!
        let buildingsLayer = ArcGISSceneLayer(url: buildingsURL)
        // Creates an elevation source from Terrain3D REST service.
        let elevationServiceURL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
        let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
        let surface = Surface()
        surface.addElevationSource(elevationSource)
        let scene = Scene()
        scene.baseSurface = surface
        scene.addOperationalLayer(buildingsLayer)
        scene.baseSurface.navigationConstraint = .unconstrained
        scene.baseSurface.opacity = 0
        return scene
    }()
    
    private let anchorPoint = Point(
        x: -122.68350326165559,
        y: 45.53257485106716,
        spatialReference: .wgs84
    )
    
    var body: some View {
        TableTopSceneView(
            anchorPoint: anchorPoint,
            translationFactor: 1_000,
            clippingDistance: 400
        ) { proxy in
            SceneView(scene: scene)
                .onSingleTapGesture { screen, _ in
                    print("Identifying...")
                    Task.detached {
                        let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                        print("\(results.count) identify result(s).")
                    }
                }
        }
    }
}
