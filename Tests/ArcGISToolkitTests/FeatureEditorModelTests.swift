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

@Suite("FeatureEditorModel Tests")
@MainActor
struct FeatureEditorModelTests {
    @Test
    func initializer() {
        let model = FeatureEditorModel()
        #expect(model.feature == nil)
        #expect(!model.isPresented)
        #expect(model.rootFeatureForm == nil)
        #expect(model.viewpointGeometry == nil)
        #expect(!model.geometryEditorCanUndo)
        #expect(model.geometryEditorGeometry == nil)
        #expect(!model.geometryEditorIsStarted)
    }
    
    @Test
    func monitorGeometryEditorStreams() async throws {
        let model = FeatureEditorModel()
        #expect(model.geometryEditorGeometry == nil)
        #expect(!model.geometryEditorIsStarted)
        let monitorTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorTask.cancel() }
        
        // Starts the geometry editor with a geometry.
        let geometry = Point(x: 0, y: 0)
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
    }
}
