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
import SwiftUI

public struct DataView: View {
    let geoModel: GeoModel
    
    public init(geoModel: GeoModel) {
        self.geoModel = geoModel
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(geoModel.operationalLayers, id: \.id) { layer in
                        NavigationLink {
                            if let gl = layer as? GroupLayer {
                                GroupLayerView(layer: gl)
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(layer.name)
                                Text(String(describing: type(of: layer)))
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text("Layers (\(geoModel.operationalLayers.count))")
                }
                Section {
                    ForEach(geoModel.tables, id: \.displayName) { table in
                        NavigationLink {} label: {
                            VStack(alignment: .leading) {
                                Text(table.displayName)
                                Text(String(describing: type(of: table)))
                                    .font(.caption)
                            }
                        }
                    }
                } header: {
                    Text("Tables (\(geoModel.tables.count))")
                }
            }
        }
    }
}

struct GroupLayerView: View {
    let layer: GroupLayer
    
    var body: some View {
        List {
            Section {
                ForEach(layer.layers, id: \.name) { layer in
                    VStack(alignment: .leading) {
                        Text(layer.name)
                        Text(String(describing: type(of: layer)))
                            .font(.caption)
                    }
                }
            } header: {
                Text("Layers (\(layer.layers.count))")
            }
        }
        .navigationTitle(layer.name, subtitle: String(describing: type(of: layer)))
    }
}
