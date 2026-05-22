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
import ArcGISToolkit
import SwiftUI

struct GeometryEditorToolbarExampleView: View {
    /// The feature whose geometry is currently being edited.
    @State private var editFeature: Feature?
    /// A description of an error that has occurred.
    @State private var error: String?
    /// The point on the screen where the user tapped.
    @State private var identifyPoint: CGPoint?
    /// A Boolean value indicating whether the geometry editor edits are being saved.
    @State private var isSavingEdits = false
    /// A map containing example point, line, and polygon features to edit.
    @State private var map: Map = {
        let url = URL(string: "https://arcgis.com/home/item.html?id=2ffa0c3601144e8bbd2c49cf3a7c0559")!
        let map = Map(url: url)!
        
        let envelope = Envelope(xRange: -13059996 ... -13021110, yRange: 4005439 ... 4068056)
        map.initialViewpoint = Viewpoint(boundingGeometry: envelope)
        
        return map
    }()
    /// The geometry editor used to edit geometries on the map.
    @State private var geometryEditor = GeometryEditor()
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .geometryEditor(geometryEditor)
                .onSingleTapGesture { screenPoint, _ in
                    guard identifyPoint == nil else { return }
                    identifyPoint = screenPoint
                }
                .task(id: identifyPoint) {
                    guard let identifyPoint else { return }
                    defer { self.identifyPoint = nil }
                    
                    do {
                        try await editFeature(at: identifyPoint, mapViewProxy: mapViewProxy)
                    } catch {
                        self.error = "\(error)"
                    }
                }
        }
        .overlay(alignment: .topTrailing) {
            GeometryEditorToolbar(geometryEditor: geometryEditor)
                .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    geometryEditor.stop()
                    editFeature?.setVisible(true)
                }
                .disabled(editFeature == nil || isSavingEdits)
                
                Button("Save", systemImage: "checkmark") {
                    isSavingEdits = true
                }
                .disabled(editFeature == nil || isSavingEdits)
                .task(id: isSavingEdits) {
                    guard isSavingEdits else { return }
                    defer { isSavingEdits = false }
                    
                    do {
                        try await saveEdits()
                    } catch {
                        self.error = "\(error)"
                    }
                }
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { error != nil },
                set: { _ in error = nil }
            ),
            actions: {},
            message: {
                Text(error ?? "An unknown error occurred")
            }
        )
    }
    
    /// Identifies features at a given screen point and starts editing its geometry.
    /// - Parameters:
    ///   - screenPoint: The point on the screen to identify.
    ///   - mapViewProxy: A map view proxy used to perform the identify operation
    private func editFeature(at screenPoint: CGPoint, mapViewProxy: MapViewProxy) async throws {
        let identifyLayerResults = try await mapViewProxy.identifyLayers(
            screenPoint: screenPoint,
            tolerance: 10
        )
        
        guard let result = identifyLayerResults.first,
              let feature = result.geoElements.first as? ArcGISFeature,
              let geometry = feature.geometry else {
            return
        }
        
        geometryEditor.start(withInitial: geometry)
        feature.setVisible(false)
        editFeature = feature
    }
    
    /// Saves the geometry editor edits to the feature being edited.
    private func saveEdits() async throws {
        let geometry = geometryEditor.stop()
        
        guard let editFeature, let table = editFeature.table else { return }
        
        editFeature.geometry = geometry
        try await table.update(editFeature)
        
        editFeature.setVisible(true)
    }
}

// MARK: - Extensions

private extension Feature {
    /// Sets the visibility of the feature on its feature layer.
    /// - Parameter visible: `true` to show the feature, otherwise `false`.
    func setVisible(_ visible: Bool) {
        guard let featureLayer = table?.layer as? FeatureLayer else { return }
        featureLayer.setVisible(visible, for: self)
    }
}
