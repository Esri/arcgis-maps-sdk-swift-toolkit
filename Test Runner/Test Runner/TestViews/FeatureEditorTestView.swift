// Copyright 2026 Esri
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
@testable import ArcGISToolkit
import SwiftUI

struct FeatureEditorTestView: View {
    /// A message describing an error thrown during test view setup.
    @State private var errorDescription: String?
    /// The feature being edited by the feature editor.
    @State private var featureToEdit: ArcGISFeature?
    /// The geometry editor used by the feature editor.
    @State private var geometryEditor = GeometryEditor()
    /// The map with a utility network displayed in the map view.
    @State private var map = makeMap()
    
    var body: some View {
        MapView(map: map)
            .geometryEditor(geometryEditor)
            .overlay(alignment: .topTrailing) {
                FeatureEditor(
                    $featureToEdit,
                    geometryEditor: geometryEditor,
                    map: map
                )
                .padding()
            }
            .task(setUpTest)
            .alert("Error", isPresented: .init(optionalValue: $errorDescription), actions: {}) {
                Text(errorDescription ?? "Unknown")
            }
    }
}

private extension FeatureEditorTestView {
    /// Identifies a feature with a given object ID and starts the
    /// feature editor with that feature's geometry.
    /// - Parameters:
    ///   - objectID: The object ID of the feature to use as a starting point.
    ///   - featureLayer: The feature layer containing the feature.
    func startEditingFeature(
        withIdentifier objectID: Int,
        on featureLayer: FeatureLayer
    ) async throws {
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
        
        try geometryEditor.snapSettings.syncSourceSettings()
        featureToEdit = feature
    }
    
    /// Sets up the test.
    func setUpTest() async {
        do {
            try await ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(.publicSample)
            try await map.retryLoad()
            
            guard let objectID = UserDefaults.standard.objectID,
                  let layerName = UserDefaults.standard.layerName,
                  let groupLayer = map.operationalLayers.first as? GroupLayer,
                  let layer = groupLayer.layers.first(where: { $0.name == layerName }),
                  let featureLayer = layer as? FeatureLayer else {
                errorDescription = "Missing or invalid launch arguments."
                return
            }
            
            try await startEditingFeature(withIdentifier: objectID, on: featureLayer)
        } catch {
            errorDescription = error.localizedDescription
        }
    }
    
    /// Makes a map from a portal item.
    static func makeMap() -> Map {
        let napervilleElectricUtilityNetwork = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("471eb0bf37074b1fbb972b1da70fb310")!
        )
        let map = Map(item: napervilleElectricUtilityNetwork)
        // Enables full resolution to allow snapping on all layers.
        map.loadSettings.featureTilingMode = .enabledWithFullResolutionWhenSupported
        return map
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
