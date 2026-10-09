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

@Suite("GeometryEditorModel Tests", .serialized)
@MainActor
struct GeometryEditorModelTests {
    @Test func `init()`() {
        let model = GeometryEditorModel()
        #expect(!model.isStarted)
        #expect(model.geometry == nil)
        #expect(model.initialGeometry == nil)
        #expect(!model.canUndo)
        #expect(
            model.selectableTools ==
            [
                .freehand,
                .vertex,
                .vertexReticle,
                .shape(kind: .arrow),
                .shape(kind: .ellipse),
                .shape(kind: .rectangle),
                .shape(kind: .triangle)
            ]
        )
        #expect(model.selectedTool == .vertex)
    }
    
    /// Verifies `monitorStreams()` updates model properties when the geometry
    /// editor starts and stops.
    @Test func monitorStreams() async {
        let model = GeometryEditorModel()
        
        let monitorTask = Task(operation: model.monitorStreams)
        defer { monitorTask.cancel() }
        
        let geometry = Point(x: 0, y: 0)
        model.geometryEditor.start(withInitial: geometry)
        try? await Task.sleep(for: .seconds(0.1))
        
        #expect(model.isStarted)
        #expect(model.geometry == geometry)
        #expect(!model.canUndo)
        
        model.geometryEditor.stop()
        await Task.yield()
        
        #expect(!model.isStarted)
        #expect(model.geometry == nil)
        #expect(!model.canUndo)
    }
}
