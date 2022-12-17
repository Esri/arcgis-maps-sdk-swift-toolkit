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

/// A demonstration of the utility network trace tool which runs traces on a web map published with a utility
/// network and trace configurations.
struct UtilityNetworkTraceExampleView: View {
    /// The data model containing a `Map` with the utility networks.
    @StateObject private var dataModel = MapDataModel(
        map: makeMap()
    )
    
    /// The current detent of the floating panel presenting the trace tool.
    @State var activeDetent: FloatingPanelDetent = .half
    
    /// Provides the ability to inspect map components.
    @State var mapViewProxy: MapViewProxy?
    
    /// Provides the ability to detect tap locations in the context of the map view.
    @State var mapPoint: Point?
    
    /// Provides the ability to detect tap locations in the context of the screen.
    @State var viewPoint: CGPoint?
    
    /// A container for graphical trace results.
    @State var resultGraphicsOverlay = GraphicsOverlay()
    
    /// The map viewpoint used by the `UtilityNetworkTrace` to pan/zoom the map to selected features.
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: dataModel.map,
                viewpoint: viewpoint,
                graphicsOverlays: [resultGraphicsOverlay]
            )
            .onSingleTapGesture { viewPoint, mapPoint in
                self.viewPoint = viewPoint
                self.mapPoint = mapPoint
                self.mapViewProxy = mapViewProxy
            }
            .onViewpointChanged(kind: .centerAndScale) {
                viewpoint = $0
            }
            .task {
                let publicSample = try? await ArcGISCredential.publicSample
                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample!)
            }
            .floatingPanel(
                    backgroundColor: Color(uiColor: .systemGroupedBackground),
                    selectedDetent: $activeDetent,
                    horizontalAlignment: .trailing,
                    isPresented: .constant(true)
            ) {
                UtilityNetworkTrace(
                    graphicsOverlay: $resultGraphicsOverlay,
                    map: dataModel.map,
                    mapPoint: $mapPoint,
                    viewPoint: $viewPoint,
                    mapViewProxy: $mapViewProxy,
                    viewpoint: $viewpoint
                )
                .floatingPanelDetent($activeDetent)
            }
        }
    }
    
    /// Makes a map from a portal item.
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        return Map(item: portalItem)
    }
}

private extension ArcGISCredential {
    static var publicSample: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}
