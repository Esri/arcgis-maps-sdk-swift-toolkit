// Copyright 2025 Esri
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

struct DataViewExampleView: View {
    @State private var dataViewIsPresented = false
    
    @State private var map: Map = {
        .init(
            url: URL(
                string: "https://maps.arcgis.com/home/item.html?id=471eb0bf37074b1fbb972b1da70fb310"
            )!
        )!
    }()
    
    var body: some View {
        MapView(map: map)
            .overlay(alignment: .bottomLeading) {
                Button {
                    dataViewIsPresented.toggle()
                } label: {
                    Label("Data", systemImage: "square.2.layers.3d")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)
            }
            .sheet(isPresented: $dataViewIsPresented) {
                DataView(map: map)
            }
    }
}
