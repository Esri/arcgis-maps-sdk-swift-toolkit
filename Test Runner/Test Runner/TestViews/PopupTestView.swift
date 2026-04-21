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

struct PopupTestView: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map()
    
    /// The popup to show in the `PopupView`.
    @State private var popup: Popup?
    
    /// The popup currently being displayed in the `PopupView`.
    @State private var selectedPopup: Popup?
    
    /// A message describing an error thrown during test view setup.
    @State private var errorDescription: String?
    
    var body: some View {
        MapView(map: map)
            .overlay(alignment: .top) {
                LabeledContent(
                    "Selected Popup Object ID",
                    value: selectedPopup?.objectID?.description ?? "nil"
                )
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(.regularMaterial, ignoresSafeAreaEdges: .horizontal)
            }
            .sheet(isPresented: .init(optionalValue: $popup)) {
                PopupView(root: popup!, isPresented: .init(optionalValue: $popup))
                    .onPopupChanged { popup in
                        // Clears the current popup selection.
                        if let feature = selectedPopup?.geoElement as? Feature,
                           let featureLayer = feature.table?.layer as? FeatureLayer {
                            featureLayer.clearSelection()
                        }
                        
                        // Selects the new popup on its feature layer.
                        if let feature = popup.geoElement as? Feature,
                           let featureLayer = feature.table?.layer as? FeatureLayer {
                            featureLayer.selectFeature(feature)
                        }
                        
                        selectedPopup = popup
                    }
            }
            .alert("Error", isPresented: .init(optionalValue: $errorDescription), actions: {}) {
                Text(errorDescription ?? "Unknown")
            }
            .task(setUpTest)
    }
    
    /// Sets up the map and popup for the test.
    private func setUpTest() async {
        do {
            try await ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(.viewer01)
            
            let map = Map(url: .napervilleElectricMap)!
            try await map.load()
            self.map = map
            
            guard let objectID = UserDefaults.standard.objectID,
                  let layerName = UserDefaults.standard.layerName,
                  let layer = map.operationalLayers.first(where: { $0.name == layerName }),
                  let featureLayer = layer as? FeatureLayer else {
                errorDescription = "Missing or invalid launch arguments."
                return
            }
            
            try await openPopup(objectID, on: featureLayer)
        } catch {
            errorDescription = error.localizedDescription
        }
    }
    
    /// Identifies a feature with a given object ID and uses it to create and open a popup.
    /// - Parameters:
    ///   - objectID: The object ID of the feature to identify.
    ///   - featureLayer: The feature layer containing the feature.
    private func openPopup(_ objectID: Int, on featureLayer: FeatureLayer) async throws {
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
        
        // Creates and opens a popup using the identified feature.
        let popupDefinition = featureTable.popupDefinition(for: feature)
        popup = Popup(geoElement: feature, definition: popupDefinition)
    }
}

// MARK: - Extensions

private extension ArcGISCredential {
    /// The "viewer01" user credentials for the Naperville Electric Map.
    static var viewer01: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: .napervilleElectricMap,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}

private extension Popup {
    /// The `objectid` attribute of the popup's geo element.
    var objectID: Int64? {
        guard let feature = geoElement as? Feature else {
            return nil
        }
        return feature.attributes["objectid"] as? Int64
    }
}

private extension URL {
    /// The URL to the "Naperville Electric Map (Popup Associations List)" web map.
    static var napervilleElectricMap: Self {
        .init(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
    }
}
