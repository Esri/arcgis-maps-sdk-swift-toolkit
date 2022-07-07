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
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @StateObject private var map = Map(basemapStyle: .arcGISImagery)
    
    private let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    var body: some View {
        MapView(
            map: map,
            viewpoint: initialViewpoint
        )
        .overlay(alignment: .topTrailing) {
            FloatingPanel {
                SampleContent()
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 360 : .infinity)
        }
    }
}

struct SampleContent: View {
    var body: some View {
        List(1..<21) { Text("\($0)") }
            .listStyle(.plain)
    }
}
