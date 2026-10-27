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

internal import os

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
    private(set) var geometry: Geometry?
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var isStarted = false
    /// The geometry that was used to start the current editing session.
    private(set) var initialGeometry: Geometry?
    /// The geometry type that was used to start the current editing session.
    private var geometryType: Geometry.Type?
    
    /// A Boolean value indicating whether the geometry has edits.
    var hasGeometryEdits: Bool {
        guard isStarted,
              let currentGeometry = geometry,
              currentGeometry != initialGeometry,
              initialGeometry != nil || !currentGeometry.isEmpty else {
            return false
        }
        return true
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
    /// - Parameter geometry: The initial geometry to start the editing session
    /// with.
    func start(withInitial geometry: Geometry) {
        initialGeometry = geometry
        geometryType = nil
        geometryEditor.start(withInitial: geometry)
        didStartGeometryEditor()
    }
    
    /// Starts the geometry editor with a geometry type.
    /// - Parameter geometryType: The type of the geometry to edit.
    func start(withType geometryType: Geometry.Type) {
        initialGeometry = nil
        self.geometryType = geometryType
        geometryEditor.start(withType: geometryType)
        didStartGeometryEditor()
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
    
    /// Called after the geometry editor has been started.
    private func didStartGeometryEditor() {
        let defaultTool = defaultConstructionTool ?? availableTools.first ?? .vertex
        if selectedTool != defaultTool {
            selectedTool = defaultTool
        }
    }
    
    /// Stops the geometry editor and resets the session state.
    func stop() {
        geometryEditor.stop()
        canUndo = false
        geometry = nil
        isStarted = false
        initialGeometry = nil
        geometryType = nil
        if constructionTools != nil {
            constructionTools = nil
        }
        if defaultConstructionTool != nil {
            defaultConstructionTool = nil
        }
        if snapRules != nil {
            snapRules = nil
        }
        if snapSettingsAreBeingModified {
            snapSettingsAreBeingModified = false
        }
    }
    
    // MARK: Snapping
    
    /// The snap rules used to sync snap source settings.
    @ObservationIgnored
    private var snapRules: SnapRules?
    /// A Boolean value indicating whether the snap settings are currently being
    /// modified.
    var snapSettingsAreBeingModified = false
    
    /// Sets the given snap rules to the model.
    /// - Parameter snapRules: The new snap rules.
    func setSnapRules(_ snapRules: SnapRules?) {
        self.snapRules = snapRules
        syncSnapSourceSettings()
    }
    
    /// Syncs the `geometryEditor.snapSettings`' source settings.
    func syncSnapSourceSettings() {
        do {
            let snapSettings = geometryEditor.snapSettings
            
            if let snapRules {
                try snapSettings.syncSourceSettings(
                    rules: snapRules,
                    sourceEnablingBehavior: .preserve
                )
            } else {
                try snapSettings.syncSourceSettings()
            }
            
            // Snapping is enabled by default to simplify the `SnapSettingsView`
            // UI.
            snapSettings.isEnabled = true
        } catch {
            Logger.featureEditor.error(
                "Error syncing snap source settings: \(error.localizedDescription)"
            )
        }
    }
    
    // MARK: Tools
    
    /// The currently selected tool.
    var selectedTool: FeatureEditorGeometryTool = .vertex {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }
    
    /// The tools to use when constructing a geometry.
    private var constructionTools: [FeatureEditorGeometryTool]?
    /// The default tool when constructing a geometry.
    private var defaultConstructionTool: FeatureEditorGeometryTool?
    
    /// Sets the construction tools and selected tool.
    /// - Parameters:
    ///   - constructionTools: The tools to use when constructing a geometry.
    ///   - default: The default construction tool.
    func setConstructionTools(
        _ constructionTools: [FeatureEditorGeometryTool],
        default: FeatureEditorGeometryTool?
    ) {
        self.constructionTools = constructionTools
        self.defaultConstructionTool = `default`
    }
    
    /// The tools that are currently able to be selected.
    var availableTools: [FeatureEditorGeometryTool] {
        if let constructionTools {
            constructionTools
        } else if let geometry, case let geometryType = type(of: geometry) {
            FeatureEditorGeometryTool.allCases.filter { tool in
                tool.supportedGeometryTypes
                    .contains(where: { $0 == geometryType })
            }
        } else {
            FeatureEditorGeometryTool.allCases
        }
    }
}
