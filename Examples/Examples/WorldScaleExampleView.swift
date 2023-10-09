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

struct WorldScaleExampleView: View {
    @State private var scene: ArcGIS.Scene = {
//        // Creates an elevation source from Terrain3D REST service.
//        let elevationServiceURL = URL(string: "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer")!
//        let elevationSource = ArcGISTiledElevationSource(url: elevationServiceURL)
//        let surface = Surface()
//        surface.addElevationSource(elevationSource)
        let scene = Scene()
//        scene.baseSurface = surface
        scene.baseSurface.backgroundGrid.isVisible = false
//        scene.baseSurface.navigationConstraint = .unconstrained
        scene.basemap = Basemap(style: .arcGISImagery)
        scene.addOperationalLayer(.canyonCountyParcels)
        return scene
    }()
    
    @State private var opacity: Float = 1
    
    var body: some View {
        VStack {
            WorldScaleSceneView2 { proxy in
                SceneView(scene: scene)
                    .onSingleTapGesture { screen, _ in
                        print("Identifying...")
                        Task.detached {
                            let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
                            print("\(results.count) identify result(s).")
                        }
                    }
            }
            Slider(value: $opacity, in: 0...1.0)
                .padding(.horizontal)
        }
        .onChange(of: opacity) { opacity in
            guard let basemap = scene.basemap else { return }
            for layer in basemap.baseLayers {
                layer.opacity = opacity
            }
        }
    }
}

extension FeatureTable {
    static var canyonCountyParcels: ServiceFeatureTable {
        ServiceFeatureTable(url: URL(string: "https://services6.arcgis.com/gcOKRHSENxBrmPoN/arcgis/rest/services/Parcels/FeatureServer/6")!)
    }
}

extension Layer {
    static var canyonCountyParcels: FeatureLayer {
        let fl = FeatureLayer(featureTable: .canyonCountyParcels)
        fl.renderer = SimpleRenderer(symbol: SimpleLineSymbol(color: .yellow, width: 3))
        return fl
    }
}
