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
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The floating panel's currently selected detent.
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
    /// The popup to be shown in the `PopupView`.
    @State private var popup: Popup?
    
    /// A message describing an error thrown during test view setup.
    @State private var errorDescription: String?
    
    var body: some View {
        MapView(map: map)
            .onAttributionBarHeightChanged { attributionBarHeight = $0 }
            .floatingPanel(
                attributionBarHeight: attributionBarHeight,
                selectedDetent: $floatingPanelDetent,
                horizontalAlignment: .leading,
                isPresented: .init(optionalValue: $popup)
            ) { [popup] in
                PopupView(popup: popup!, isPresented: .init(optionalValue: $popup))
            }
            .alert("Error", isPresented: .init(optionalValue: $errorDescription), actions: {}) {
                Text(errorDescription ?? "Unknown")
            }
            .task {
                // Sets up the map and opens a popup when the view appears.
                do {
                    try await ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(
                        .viewer01
                    )
                    
                    let map = Map(url: .napervilleElectricMap)!
                    try await map.load()
                    self.map = map
                    
                    try await openPopup(usingValuesIn: .standard, on: map)
                } catch {
                    errorDescription = error.localizedDescription
                }
            }
    }
    
    /// Identifies a feature matching launch argument values and uses it to
    /// create and open a popup.
    /// - Parameters:
    ///   - userDefaults: The user defaults containing the `-objectID` and
    ///   `-layerName` launch argument values of the feature to be identified.
    ///   - map: The map with the feature layer to identify on.
    private func openPopup(usingValuesIn userDefaults: UserDefaults, on map: Map) async throws {
        // Gets the object ID from the launch arguments.
        guard let objectIDText = userDefaults.string(forKey: "objectID"),
              let objectID = Int(objectIDText) else {
            errorDescription = "Missing or invalid \"-objectID\" argument."
            return
        }
        
        // Gets feature layer from the map using the launch argument.
        guard let layerName = userDefaults.string(forKey: "layerName"),
              let layer = map.operationalLayers.first(where: { $0.name == layerName }),
              let featureLayer = layer as? FeatureLayer else {
            errorDescription = "Missing or invalid \"-layerName\" argument."
            return
        }
        
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
        featureLayer.selectFeature(feature)
        
        // Creates and opens a popup using the identified feature.
        let popupDefinition = featureTable.popupDefinition(for: feature)
        popup = Popup(geoElement: feature, definition: popupDefinition)
    }
}

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

private extension Binding where Value == Bool {
    /// Creates a Boolean binding that wraps a binding to an optional.
    ///
    /// `wrappedValue` is `true` when the given optional value is non-`nil`. The
    /// optional value is set to `nil` when the parent binding is set.
    /// - Parameter optionalValue: A binding to the optional value to wrap.
    init<T: Sendable>(optionalValue: Binding<T?>) {
        self.init {
            optionalValue.wrappedValue != nil
        } set: { _ in
            optionalValue.wrappedValue = nil
        }
    }
}

private extension URL {
    /// The URL to the "Naperville Electric Map (Popup Associations List)" web map.
    static var napervilleElectricMap: Self {
        .init(string: "https://sampleserver7.arcgisonline.com/portal/home/item.html?id=b4565e0a4e4c4a4382914128f10864cd")!
    }
}
