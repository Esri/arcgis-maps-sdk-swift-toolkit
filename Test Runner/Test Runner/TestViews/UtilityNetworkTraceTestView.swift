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

/// A demonstration of the utility network trace tool which runs traces on a web map published with
/// a utility network and trace configurations.
struct UtilityNetworkTraceTestView: View {
    /// The map with the utility networks.
    @State private var map = makeMap()
    /// Provides the ability to detect tap locations in the context of the map view.
    @State private var mapPoint: Point?
    /// A container for graphical trace results.
    @State private var resultGraphicsOverlay = GraphicsOverlay()
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map, graphicsOverlays: [resultGraphicsOverlay])
                .onSingleTapGesture { _, mapPoint in
                    self.mapPoint = mapPoint
                }
                .floatingPanel(
                    backgroundColor: Color(uiColor: .systemGroupedBackground),
                    horizontalAlignment: .trailing,
                    isPresented: .constant(true)
                ) {
                    UtilityNetworkTrace(
                        graphicsOverlay: $resultGraphicsOverlay,
                        map: map,
                        mapPoint: $mapPoint,
                        mapViewProxy: mapViewProxy
                    )
                }
                .task {
                    do {
                        let publicSample = try await ArcGISCredential.publicSample
                        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample)
                    } catch {
                        print("Error creating credential:", error.localizedDescription)
                    }
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
                for: URL(string: "https://sampleserver7.arcgisonline.com/portal")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}
