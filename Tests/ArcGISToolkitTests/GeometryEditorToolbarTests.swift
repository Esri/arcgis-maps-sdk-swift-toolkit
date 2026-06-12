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

@Suite("GeometryEditorToolbar Tests")
@MainActor
struct GeometryEditorToolbarTests {
    @Test
    func modelInitializer() {
        let geometryEditor = GeometryEditor()
        let model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
        
        #expect(model.geometryEditor === geometryEditor)
        #expect(!model.isStarted)
    }
    
    @Test
    func modelIsStartedStateChanges() async throws {
        let geometryEditor = GeometryEditor()
        let model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
        #expect(!model.isStarted)
        geometryEditor.start(withType: Point.self)
        try await Task.yield(timeout: 0.1) { @MainActor in
            model.isStarted
        }
        #expect(model.isStarted)
        
        geometryEditor.stop()
        try await Task.yield(timeout: 0.1) { @MainActor in
            !model.isStarted
        }
        #expect(!model.isStarted)
    }
    
    @Test
    func snapSourcesAllContainsAllSupportedTypes() {
        let all = GeometryEditorToolbar.SnapSources.all
        #expect(all == [.featureLayer, .graphicsOverlay, .subtypeFeatureLayer, .subtypeSublayer])
    }
    
    @Test
    func snapSourcesLayersOnlyContainLayers() {
        let layers = GeometryEditorToolbar.SnapSources.layers
        #expect(layers == [.featureLayer, .subtypeFeatureLayer, .subtypeSublayer])
    }
}
