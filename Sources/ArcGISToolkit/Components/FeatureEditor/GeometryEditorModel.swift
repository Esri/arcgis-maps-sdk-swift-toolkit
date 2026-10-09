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

/// A data model that contains the state needed to use a geometry editor.
@MainActor
@Observable
final class GeometryEditorModel {
    /// The geometry editor used to edit geometries.
    var geometryEditor = GeometryEditor() {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }
    /// A Boolean value indicating whether the geometry editor has edits to
    /// undo.
    private(set) var canUndo = false
    /// The geometry editor's current geometry.
    private(set) var geometry: Geometry? {
        didSet {
            updateSelectableTools()
        }
    }
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var isStarted = false
    /// The geometry that was used to start the current editing session.
    private(set) var initialGeometry: Geometry?
    /// The geometry type that was used to start the current editing session.
    private var geometryType: Geometry.Type?
    /// The tools that are currently able to be selected.
    private(set) var selectableTools = FeatureEditorGeometryTool.allCases
    /// The template-specific tools currently used to construct geometry.
    private var constructionTools: [FeatureEditorGeometryTool]?
    /// The tool selected by the picker.
    var selectedTool: FeatureEditorGeometryTool = .vertex {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }

    /// Monitors geometry editor streams and updates the corresponding
    /// properties.
    func monitorStreams() async {
        await withTaskGroup { group in
            group.addTask { @MainActor @Sendable in
                for await canUndo in self.geometryEditor.$canUndo {
                    self.canUndo = canUndo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await geometry in self.geometryEditor.$geometry {
                    self.geometry = geometry
                }
            }
            group.addTask { @MainActor @Sendable in
                for await isStarted in self.geometryEditor.$isStarted {
                    self.isStarted = isStarted
                }
            }
        }
    }

    /// Starts the geometry editor with an initial geometry.
    func start(withInitial geometry: Geometry) {
        initialGeometry = geometry
        geometryType = nil
        geometryEditor.start(withInitial: geometry)
    }

    /// Starts the geometry editor with a geometry type.
    func start(withType geometryType: Geometry.Type) {
        initialGeometry = nil
        self.geometryType = geometryType
        geometryEditor.start(withType: geometryType)
    }

    /// Sets the tools available for the current geometry editing session.
    /// - Parameters:
    ///   - tools: The tools that can be selected.
    ///   - selectedTool: The initial selected tool.
    func setSelectableTools(
        _ tools: [FeatureEditorGeometryTool],
        selectedTool: FeatureEditorGeometryTool?
    ) {
        constructionTools = tools
        selectableTools = tools
        self.selectedTool = selectedTool ?? tools.first ?? .vertex
    }

    /// Restarts the geometry editor if it is started.
    func restart() {
        guard isStarted else { return }

        if let initialGeometry {
            start(withInitial: initialGeometry)
        } else if let geometryType {
            start(withType: geometryType)
        }
    }

    /// Stops the geometry editor and resets the session state.
    /// - Parameter resetTools: Whether to reset the tools configured for the
    /// session.
    func stop(resetTools: Bool = true) {
        geometryEditor.stop()
        canUndo = false
        geometry = nil
        isStarted = false
        initialGeometry = nil
        geometryType = nil
        if resetTools {
            constructionTools = nil
            selectableTools = FeatureEditorGeometryTool.allCases
        }
    }

    /// Updates the tools available for the current geometry.
    private func updateSelectableTools() {
        selectableTools = if let constructionTools {
            constructionTools
        } else if let geometry, case let geometryType = type(of: geometry) {
            FeatureEditorGeometryTool.allCases
                .filter { tool in
                    tool.supportedGeometryTypes.contains(where: { $0 == geometryType })
                }
        } else {
            FeatureEditorGeometryTool.allCases
        }

        guard !selectableTools.contains(selectedTool),
              let firstValidTool = selectableTools.first else {
            return
        }
        
        selectedTool = firstValidTool
    }
}
