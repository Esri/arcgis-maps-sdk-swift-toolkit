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
import SwiftUI

// MARK: - Geometry Editor Model

@MainActor
@Observable
final class GeometryEditorModel {
    var geometryEditor = GeometryEditor()
    private(set) var geometryType: Geometry.Type?
    
    // MARK: GeometryEditor
    
    private(set) var canRedo = false
    private(set) var canUndo = false
    private(set) var geometry: Geometry?
    private(set) var isStarted = false
    private(set) var selectedElement: GeometryEditorElement?
    
    var canDeleteSelectedElement: Bool {
        selectedElement?.canBeDeleted ?? false
    }
    
    func monitorStreams() async {
        await withTaskGroup { group in
            group.addTask { @MainActor @Sendable in
                for await canRedo in self.geometryEditor.$canRedo {
                    self.canRedo = canRedo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await canUndo in self.geometryEditor.$canUndo {
                    self.canUndo = canUndo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await geometry in self.geometryEditor.$geometry {
                    self.geometry = geometry
                    
                    // Sets the geometry type when the editor is started.
                    guard let geometry else { continue }
                    self.geometryType = type(of: geometry)
                }
            }
            group.addTask { @MainActor @Sendable in
                for await selectedElement in self.geometryEditor.$selectedElement {
                    self.selectedElement = selectedElement
                }
            }
            group.addTask { @MainActor @Sendable in
                for await isStarted in self.geometryEditor.$isStarted {
                    self.isStarted = isStarted
                    
                    // Clears the geometry type when the editor is stopped.
                    guard !isStarted else { continue }
                    self.geometryType = nil
                }
            }
        }
    }
    
    func start(
        withInitial geometry: Geometry,
        file: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function
    ) {
        print("[model.start] \(file):\(line) \(function)")
        geometryEditor.start(withInitial: geometry)
    }
    
    func start(
        withType geometryType: Geometry.Type,
        file: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function
    ) {
        print("[model.start \(geometryType)] \(file):\(line) \(function)")
        geometryEditor.start(withType: geometryType)
    }
    
    func save(
        file: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function
    ) -> Geometry? {
        print("[model.save] \(file):\(line) \(function)")
//        return Point(latitude: 0, longitude: 0)
        return geometry
    }
    
    func stop(
        file: StaticString = #fileID,
        line: UInt = #line,
        function: StaticString = #function
    ) {
        print("[model.stop] \(file):\(line) \(function)")
        geometryEditor.stop()
    }
}
