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
    }
    
    /// Starts the geometry editor with a geometry type.
    /// - Parameter geometryType: The type of the geometry to edit.
    func start(withType geometryType: Geometry.Type) {
        initialGeometry = nil
        self.geometryType = geometryType
        geometryEditor.start(withType: geometryType)
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
    func stop() {
        geometryEditor.stop()
        canUndo = false
        geometry = nil
        isStarted = false
        initialGeometry = nil
        geometryType = nil
    }
    
    // MARK: Snapping
    
    /// The snap rules used to sync snap source settings.
    @ObservationIgnored
    private var snapRules: SnapRules?
    /// A Boolean value indicating whether the snap settings sheet is presented.
    /// This is needed to display the sheet from the modifier to prevent it from
    /// dismissing the feature editor when the horizontal size class is compact.
    var snapSettingsSheetIsPresented = false
    
    /// Sets the given snap rules to the model
    /// - Parameter snapRules: The new snap rules.
    func setSnapRules(_ snapRules: SnapRules?) {
        self.snapRules = snapRules
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
    
    /// The tools that are currently able to be selected.
    private(set) var selectableTools = FeatureEditorGeometryTool.allCases
    /// The currently selected tool..
    var selectedTool: FeatureEditorGeometryTool = .vertex {
        didSet {
            geometryEditor.tool = selectedTool.geometryEditorTool
        }
    }
    
    /// Updates the tools available for the current geometry.
    private func updateSelectableTools() {
        selectableTools = if let geometry, case let geometryType = type(of: geometry) {
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
