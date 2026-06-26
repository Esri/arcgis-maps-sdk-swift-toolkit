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
import Observation

/// A data model that contains various properties that are needed for the
/// feature editor and shared between the modifier and the view.
@MainActor
@Observable
final class FeatureEditorModel {
    /// The feature form to edit with the feature editor.
    var featureForm: FeatureForm?
    /// The geometry used to set the viewpoint.
    var viewpointGeometry: Geometry?
    
    // MARK: Geometry Editor
    
    /// The geometry editor that the feature editor will use to edit geometries on the `MapView`.
    var geometryEditor = GeometryEditor()
    /// A Boolean value indicating whether the geometry editor has edits to undo.
    private(set) var geometryEditorCanUndo = false
    /// The geometry editor's current geometry.
    private(set) var geometryEditorGeometry: Geometry?
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var geometryEditorIsStarted = false
    
    /// Monitors geometry editor streams and updates the corresponding properties.
    func monitorGeometryEditorStreams() async {
        await withTaskGroup { group in
            group.addTask { @MainActor @Sendable in
                for await canUndo in self.geometryEditor.$canUndo {
                    self.geometryEditorCanUndo = canUndo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await geometry in self.geometryEditor.$geometry {
                    self.geometryEditorGeometry = geometry
                }
            }
            group.addTask { @MainActor @Sendable in
                for await isStarted in self.geometryEditor.$isStarted {
                    self.geometryEditorIsStarted = isStarted
                }
            }
        }
    }
}
