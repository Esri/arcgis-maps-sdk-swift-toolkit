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
import Testing

@Suite("FeatureEditor Tests")
@MainActor
struct FeatureEditorTests {
    @Test
    func modelInitializer() {
        let model = FeatureEditorModel()
        #expect(model.featureForm == nil)
        #expect(!model.geometryEditorCanUndo)
        #expect(model.geometryEditorGeometry == nil)
        #expect(!model.geometryEditorIsStarted)
    }
    
    @Test
    func geometryEditorIsStartedStateChanges() async throws {
        // Loads a Naperville water network web map with a feature layer and
        // queries a feature to create a feature form.
        let map = Map(item: PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
        ))
        try await map.load()
        let layer = try #require(map.operationalLayers.first { $0.name == "Main" } as? FeatureLayer)
        let parameters = QueryParameters()
        parameters.addObjectID(3651)
        let result = try await #require(layer.featureTable?.queryFeatures(using: parameters))
        let feature = try #require(result.features().makeIterator().next() as? ArcGISFeature)
        let featureForm = FeatureForm(feature: feature)
        let geometry = try #require(feature.geometry)
        
        // Creates a model and starts the geometry editor with the feature form
        // and geometry.
        let model = FeatureEditorModel()
        #expect(!model.geometryEditorIsStarted)
        #expect(model.geometryEditorGeometry == nil)
        let monitorTask = Task { await model.monitorGeometryEditorStreams() }
        defer { monitorTask.cancel() }
        model.featureForm = featureForm
        
        // Starts the geometry editor with the feature's geometry.
        model.geometryEditor.start(withInitial: geometry)
        try await Task.yield(timeout: 0.1) { @MainActor in
            model.geometryEditorIsStarted
        }
        #expect(model.geometryEditorIsStarted)
        #expect(model.geometryEditorGeometry == geometry)
        
        // Stops the geometry editor.
        model.geometryEditor.stop()
        try await Task.yield(timeout: 0.1) { @MainActor in
            !model.geometryEditorIsStarted
        }
        #expect(!model.geometryEditorIsStarted)
        #expect(model.geometryEditorGeometry == nil)
        
        // The feature form remains the same after stopping the geometry editor.
        #expect(model.featureForm === featureForm)
    }
}
