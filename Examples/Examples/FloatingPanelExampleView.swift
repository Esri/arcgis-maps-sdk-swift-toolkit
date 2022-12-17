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

import SwiftUI
import ArcGISToolkit
import ArcGIS

struct FloatingPanelExampleView: View {
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    @State var selectedDetent: FloatingPanelDetent = .half
    
    private let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    var body: some View {
        MapView(
            map: dataModel.map,
            viewpoint: initialViewpoint
        )
        .floatingPanel(selectedDetent: $selectedDetent, isPresented: .constant(true)) {
            List {
                Section("Preset Heights") {
                    Button("Summary") {
                        selectedDetent = .summary
                    }
                    Button("Half") {
                        selectedDetent = .half
                    }
                    Button("Full") {
                        selectedDetent = .full
                    }
                }
                Section("Fractional Heights") {
                    Button("1/4") {
                        selectedDetent = .fraction(1 / 4)
                    }
                    Button("1/2") {
                        selectedDetent = .fraction(1 / 2)
                    }
                    Button("3/4") {
                        selectedDetent = .fraction(3 / 4)
                    }
                }
                Section("Value Heights") {
                    Button("200") {
                        selectedDetent = .height(200)
                    }
                    Button("600") {
                        selectedDetent = .height(600)
                    }
                }
            }
        }
    }
}
