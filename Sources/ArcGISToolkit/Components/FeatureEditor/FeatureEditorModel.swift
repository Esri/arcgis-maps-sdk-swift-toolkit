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

/// A data model that contains various properties that are needed for the
/// feature editor and shared between the modifier and the view.
@MainActor
@Observable
final class FeatureEditorModel {
    // MARK: Properties
    
    /// The feature currently being edited by the feature editor.
    var feature: ArcGISFeature? {
        presentedFeatureForm?.feature ?? rootFeatureForm?.feature
    }
    /// A Boolean value that indicates whether the Feature Editor inspector is presented.
    /// This maps `rootFeatureForm` to a Boolean value.
    var isPresented: Bool {
        get { rootFeatureForm != nil }
        set {
            guard !newValue else { return }
            stopEditing()
        }
    }
    /// The form currently presented in the feature editor's `FeatureFormView`.
    /// This is non-`nil` after a new feature form is shown in the view.
    private var presentedFeatureForm: FeatureForm?
    /// The root feature form to edit with the feature editor.
    private(set) var rootFeatureForm: FeatureForm?
    /// A Boolean value indicating whether the snap settings sheet is presented.
    /// This is needed to display the sheet from the modifier to prevent it from
    /// dismissing the feature editor when the horizontal size class is compact.
    var snapSettingsSheetIsPresented = false
    /// The geometry used to set the viewpoint.
    var viewpointGeometry: Geometry?
    
    // MARK: Geometry Editor Properties
    
    /// The geometry editor that the feature editor will use to edit geometries on the `MapView`.
    var geometryEditor = GeometryEditor()
    /// A Boolean value indicating whether the geometry editor has edits to undo.
    private(set) var geometryEditorCanUndo = false
    /// The geometry editor's current geometry.
    private(set) var geometryEditorGeometry: Geometry?
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var geometryEditorIsStarted = false
    
    // MARK: Snapping Properties
    
    /// The snap rules for the `feature`, used to sync snap source settings.
    /// This is non-`nil` when snap rules were successfully created using the `utilityNetwork`.
    private var snapRules: SnapRules?
    /// The `feature`'s utility network used to create snap rules.
    /// This is non-`nil` when a map containing the feature's UN is used to start editing.
    private var utilityNetwork: UtilityNetwork?
    
    // MARK: Methods
    
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
    
    /// Restarts the `geometryEditor` if it is started.
    /// This can be used to discard geometry edits or set up a new geometry editor.
    func restartGeometryEditor() {
        guard geometryEditorIsStarted else { return }
        startGeometryEditor()
    }
    
    /// Starts editing a new `FeatureForm` that is shown in the feature editor's `FeatureFormView`.
    /// - Parameter featureForm: The new feature form to edit.
    func startEditing(newFeatureForm featureForm: FeatureForm) async throws {
        geometryEditor.stop()
        presentedFeatureForm = featureForm
        
        try await setUpGeometryEditing()
    }
    
    /// Starts an editing session for the given `feature`.
    /// - Parameters:
    ///   - feature: The root feature to edit.
    ///   - map: The map that `feature` is part of, used to set up rule-based snapping.
    func startEditing(rootFeature feature: ArcGISFeature, on map: Map?) async throws {
        stopEditing()
        rootFeatureForm = FeatureForm(feature: feature)
        
        // Sets up the utility network so snap rules can be created.
        if let map {
            try await map.load()
            await map.utilityNetworks.load()
            utilityNetwork = map.utilityNetworks.first { utilityNetwork in
                utilityNetwork.makeElement(arcGISFeature: feature) != nil
            }
        }
        
        try await setUpGeometryEditing()
    }
    
    /// Stops the feature editor and resets the model's properties.
    ///
    /// This is needed to prevent the current state from interfering with
    /// future uses of the `FeatureEditor` view.
    func stopEditing() {
        rootFeatureForm = nil
        presentedFeatureForm = nil
        snapSettingsSheetIsPresented = false
        viewpointGeometry = nil
        
        geometryEditor.stop()
        geometryEditorCanUndo = false
        geometryEditorGeometry = nil
        geometryEditorIsStarted = false
        
        snapRules = nil
        utilityNetwork = nil
    }
    
    /// Syncs the `geometryEditor.snapSettings`' source settings.
    func syncSnapSourceSettings() {
        do {
            let snapSettings = geometryEditor.snapSettings
            
            if let rules = snapRules {
                try snapSettings.syncSourceSettings(rules: rules, sourceEnablingBehavior: .preserve)
            } else {
                try snapSettings.syncSourceSettings()
            }
            
            // Snapping is enabled by default to simplify the `SnapSettingsView` UI.
            snapSettings.isEnabled = true
        } catch {
            Logger.featureEditor.error(
                "Error syncing snap source settings: \(error.localizedDescription)"
            )
        }
    }
    
    /// Performs setup needed for geometry editing and starts the geometry editor if applicable.
    private func setUpGeometryEditing() async throws {
        guard let feature else { return }
        
        // Loads the feature so canUpdateGeometry can be accessed. It is always false otherwise.
        try await feature.load()
        guard feature.canUpdateGeometry else { return }
        
        // Loads the feature's table if the geometry is nil so geometryType can be accessed.
        // It is always nil otherwise.
        if feature.geometry == nil, let table = feature.table {
            try await table.load()
        }
        
        // Sets up the snap rules and syncs the snap source settings.
        if let utilityNetwork, let element = utilityNetwork.makeElement(arcGISFeature: feature) {
            // Errors are ignored to set snapRules to nil if creation fails, so
            // the old rules don't get used in future syncing.
            snapRules = try? await .rules(for: utilityNetwork, assetType: element.assetType)
        } else {
            snapRules = nil
        }
        syncSnapSourceSettings()
        
        startGeometryEditor()
    }
    
    /// Starts the geometry editor using the `feature`.
    private func startGeometryEditor() {
        guard let feature else { return }
        
        if let geometry = feature.geometry {
            geometryEditor.start(withInitial: geometry)
            viewpointGeometry = geometry
        } else if let geometryType = feature.table?.geometryType {
            geometryEditor.start(withType: geometryType)
        }
    }
}
