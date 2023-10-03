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

struct FlyoverExampleView: View {
    @State private var scene = Scene(
        item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
        )
    )

//    var body: some View {
//        FlyoverSceneView(
//            initialLocation: Point(x: 4.4777, y: 51.9244, z: 1_000, spatialReference: .wgs84),
//            initialHeading: 0,
//            translationFactor: 2_000
//        ) { proxy in
//            SceneView(scene: scene)
//                .onSingleTapGesture { screen, _ in
//                    print("Identifying...")
//                    Task.detached {
//                        let results = try await proxy.identifyLayers(screenPoint: screen, tolerance: 20)
//                        print("\(results.count) identify result(s).")
//                    }
//                }
//        }
//    }
    
    @State var lat = 43.54
    @State var tf = 2000.0
    
    var body: some View {
        VStack {
            FlyoverSceneView(
                initialLatitude: lat,
                initialLongitude: -116.5794293050851,
                initialAltitude: 3300,
                initialHeading: 0,
                translationFactor: tf
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
            HStack {
                Button {
                    lat += 5
                } label: {
                    Text("lat")
                }
                Spacer()
                Button {
                    tf += 1000
                } label: {
                    Text("tf")
                }
            }
            .padding()
        }
    }
}
