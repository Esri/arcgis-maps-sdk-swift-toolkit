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
    /// A message describing an error thrown during test view setup.
    @State private var errorDescription: String?
    /// The map with the utility networks.
    @State private var map = makeMap()
    /// Provides the ability to detect tap locations in the context of the map view.
    @State private var mapPoint: Point?
    /// A container for graphical trace results.
    @State private var resultGraphicsOverlay = GraphicsOverlay()
    /// The set of programatic trace starting points.
    @State private var startingPoints: [UtilityNetworkTraceStartingPoint] = []
    
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
                        mapViewProxy: mapViewProxy,
                        startingPoints: $startingPoints
                    )
                }
                .alert("Error", isPresented: .init(optionalValue: $errorDescription), actions: {}) {
                    Text(errorDescription ?? "Unknown")
                }
                .task(setUpTest)
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

private extension UtilityNetworkTraceTestView {
    /// Identifies a feature with a given object ID and uses it to create and add a trace starting point.
    /// - Parameters:
    ///   - objectID: The object ID of the feature to use as a starting point.
    ///   - featureLayer: The feature layer containing the feature.
    func addStartingPoint(_ objectID: Int, on featureLayer: FeatureLayer) async throws {
        // Gets the feature table from the layer.
        try await featureLayer.load()
        guard let featureTable = featureLayer.featureTable else {
            errorDescription = "No table to query on layer \"\(featureLayer.name)\"."
            return
        }
        
        try await featureTable.load()
        
        // Queries the table using the object ID.
        let parameters = QueryParameters()
        parameters.addObjectID(objectID)
        
        let result = try await featureTable.queryFeatures(using: parameters)
        guard let feature = result.features().makeIterator().next() as? ArcGISFeature else {
            errorDescription = "No feature \"\(objectID)\" in feature table \"\(featureTable.tableName)\"."
            return
        }
        
        try await feature.load()
        
        // Creates and adds a utility network trace starting point.
        let startingPoint = UtilityNetworkTraceStartingPoint(geoElement: feature)
        startingPoints.append(startingPoint)
    }
    
    /// Sets up the test.
    func setUpTest() async {
        do {
            try await ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(.publicSample)
            
            guard let objectID = UserDefaults.standard.objectID,
                  let layerName = UserDefaults.standard.layerName,
                  let groupLayer = map.operationalLayers.first as? GroupLayer,
                  let layer = groupLayer.layers.first(where: {$0.name == layerName }),
                  let featureLayer = layer as? FeatureLayer else {
                errorDescription = "Missing or invalid launch arguments."
                return
            }
            
            try await addStartingPoint(objectID, on: featureLayer)
        } catch {
            errorDescription = error.localizedDescription
        }
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
