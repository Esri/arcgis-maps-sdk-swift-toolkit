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
    /// The map containing the utility networks.
    @StateObject private var map = makeMap()
    
    /// Provides the ability to inspect map components.
    @State var mapViewProxy: MapViewProxy?
    
    /// Provides the ability to detect tap locations in the context of the map view.
    @State var mapPoint: Point?
    
    /// Provides the ability to detect tap locations in the context of the screen.
    @State var viewPoint: CGPoint?
    
    /// A container for graphical trace results.
    @State var resultGraphicsOverlay = GraphicsOverlay()
    
    /// Optional pre-defined starting points for the utility network trace.
    @State var startingPoints: [UtilityNetworkTraceStartingPoint] = []
    
    /// The map viewpoint used by the `UtilityNetworkTrace` to pan/zoom the map to selected features.
    @State var viewpoint: Viewpoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(
                map: map,
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
            .overlay(alignment: .topTrailing) {
                FloatingPanel {
                    UtilityNetworkTrace(
                        graphicsOverlay: $resultGraphicsOverlay,
                        map: map,
                        mapPoint: $mapPoint,
                        viewPoint: $viewPoint,
                        mapViewProxy: $mapViewProxy,
                        viewpoint: $viewpoint,
                        startingPoints: $startingPoints
                    )
                    .task {
                        await ArcGISRuntimeEnvironment.credentialStore.add(try! await .publicSample)
                    }
                }
                .padding()
                .frame(width: 360)
            }
            .overlay(alignment: .topLeading) {
                Button {
                    Task {
                        await setPredefinedStartingPoints()
                    }
                } label: {
                    Text("Set predefined starting points")
                }
                .buttonStyle(.borderedProminent)
                .padding()
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

extension UtilityNetworkTraceExampleView {
    /// Queries the map for a feature with a certain ID and sets the list of starting points.
    func setPredefinedStartingPoints() async {
        let targetID = UUID(uuidString: "2A6D25D5-8B9E-400A-BC07-4A11BD8B6C82")
        guard let groupLayer = map.operationalLayers.first as? GroupLayer else { return }
        let parameters = QueryParameters()
        parameters.addObjectID(1740)
        for layer in groupLayer.layers {
            guard let layer = layer as? FeatureLayer,
                  let table = layer.featureTable else { continue }
            let query = try? await table.queryFeatures(parameters: parameters)
            query?.features().forEach { element in
                if let feature = element as? ArcGISFeature,
                   let id = feature.attributes["globalid"] as? UUID,
                   id == targetID {
                    startingPoints = [
                        UtilityNetworkTraceStartingPoint(geoElement: element)
                    ]
                }
            }
        }
    }
}
