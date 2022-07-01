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
    @StateObject private var map = makeMap()
    
    /// Provides the ability to inspect map components.
    @State var mapViewProxy: MapViewProxy?
    
    /// Provides the ability to detect tap locations in the context of the map view.
    @State var pointInMap: Point?
    
    /// Provides the ability to detect tap locations in the context of the screen.
    @State var pointInScreen: CGPoint?
    
    /// A container for graphical trace results.
    @State var resultGraphicsOverlay = GraphicsOverlay()
    
    /// The map viewpoint used by the `UtilityNetworkTrace` to pan/zoom the map to selected features.
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: map,
                viewpoint: viewpoint,
                graphicsOverlays: [resultGraphicsOverlay]
            )
            .onSingleTapGesture { pointInScreen, pointInMap in
                self.pointInScreen = pointInScreen
                self.pointInMap = pointInMap
                self.mapViewProxy = mapViewProxy
            }
            .overlay(alignment: .topTrailing) {
                FloatingPanel {
                    UtilityNetworkTrace(
                        $resultGraphicsOverlay,
                        map,
                        $pointInMap,
                        $pointInScreen,
                        $mapViewProxy,
                        $viewpoint
                    )
                    .task {
                        await ArcGISURLSession.credentialStore.add(try! await .publicSample)
                    }
                }
                .padding()
                .frame(width: 360)
            }
        }
    }
    
    /// Makes a map from a portal item.
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(isLoginRequired: false),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        return Map(item: portalItem)
    }
}

private extension ArcGISCredential {
    static var publicSample: ArcGISCredential {
        get async throws {
            try await .token(
                url: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}
