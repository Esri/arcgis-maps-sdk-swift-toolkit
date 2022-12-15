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

struct ScalebarExampleView: View {
    /// Allows for communication between the `Scalebar` and `MapView`.
    @State private var spatialReference: SpatialReference?
    
    /// Allows for communication between the `Scalebar` and `MapView`.
    @State private var unitsPerPoint: Double?
    
    /// Allows for communication between the `Scalebar` and `MapView`.
    @State private var viewpoint: Viewpoint?
    
    /// The location of the scalebar on screen.
    private let alignment: Alignment = .bottomLeading
    
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISTopographic)
    )
    
    /// The maximum screen width allotted to the scalebar.
    private let maxWidth: Double = 175.0
    
    var body: some View {
        MapView(map: dataModel.map)
            .onSpatialReferenceChanged { spatialReference = $0 }
            .onUnitsPerPointChanged { unitsPerPoint = $0 }
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(alignment: alignment) {
                Scalebar(
                    maxWidth: maxWidth,
                    spatialReference: $spatialReference,
                    unitsPerPoint: $unitsPerPoint,
                    viewpoint: $viewpoint
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 50)
            }
    }
}
