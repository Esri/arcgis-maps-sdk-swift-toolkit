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
    // MARK: State
    
    /// The various states of the feature editor.
    enum State: Equatable {
        /// The feature editor is adding features.
        case adding
        /// The feature editor is editing a feature.
        case editing
        /// The feature editor is stopped.
        case stopped
    }
    
    /// The current state of the feature editor.
    private(set) var state: State = .stopped
    
    // MARK: Properties
    
    /// The feature currently being edited by the feature editor.
    var feature: ArcGISFeature? {
        presentedFeatureForm?.feature ?? rootFeatureForm?.feature
    }
    /// The geometry of the `feature` before editing.
    private(set) var initialGeometry: Geometry?
    /// A Boolean value that indicates whether the Feature Editor inspector is presented.
    var isPresented: Bool {
        get { state != .stopped }
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
    /// The result of trying to load the resources and starting editing.
    private(set) var loadResult: Result<Void, Error>?
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
    /// The snap rules for the `feature`, used to sync snap source settings.
    /// These are created when `feature` is part of an available utility network.
    @ObservationIgnored
    private var snapRules: SnapRules?
    
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
    func restartGeometryEditor() async {
        guard geometryEditorIsStarted else { return }
        
        do {
            try await setFormGeometry(to: initialGeometry)
        } catch {
            Logger.featureEditor.error(
                "Error updating form geometry: \(error.localizedDescription)"
            )
        }
        startGeometryEditor()
    }
    
    // MARK: Adding
    
    /// Adds shared templates from all operational layers of the map to this
    /// model.
    /// - Parameter map: The map from whose operational layers the shared
    /// templates should be populated.
    func populateSharedTemplates(from map: Map?) async throws {
        try await featureAddingModel.populateSharedTemplates(from: map)
    }
    
    /// A Boolean value indicating whether the feature editor supports adding
    /// features.
    var supportsAddingFeatures: Bool { !featureAddingModel.groups.isEmpty }
    
    /// The model for adding features.
    var featureAddingModel: FeatureAddingModel {
        if _featureAdding == nil {
            _featureAdding = FeatureAddingModel(featureEditorModel: self)
        }
        return _featureAdding!
    }
    @ObservationIgnored private var _featureAdding: FeatureAddingModel?
    
    /// Starts adding new features from templates.
    func startAddingFeatures() {
        guard supportsAddingFeatures else { return }
        state = .adding
    }
    
    /// Stops adding new features.
    func stopAddingFeatures() {
        state = .stopped
        stopGeometryEditing()
    }
    
    // MARK: Editing
    
    /// Starts editing a new `FeatureForm` that is shown in the feature editor's `FeatureFormView`.
    /// - Parameter featureForm: The new feature form to edit.
    func startEditingFeatureForm(_ featureForm: FeatureForm) async {
        stopGeometryEditing()
        presentedFeatureForm = featureForm
        await setUpGeometryEditing()
    }
    
    /// Starts an editing session for the given `feature`.
    /// - Parameter feature: The root feature to edit.
    func startEditingFeature(_ feature: ArcGISFeature) async {
        state = .editing
        resetProperties()
        rootFeatureForm = FeatureForm(feature: feature)
        await setUpGeometryEditing()
    }
    
    /// Retries starting an editing session.
    func retryStartEditing() async {
        // Makes sure the previous load failed and sets the loadResult to nil.
        guard case .failure = loadResult.take() else { return }
        await setUpGeometryEditing()
    }
    
    /// Stops the feature editor and resets the model's properties.
    ///
    /// This is needed to prevent the current state from interfering with
    /// future uses of the `FeatureEditor` view.
    func stopEditing() {
        state = .stopped
        resetProperties()
    }
    
    /// Resets the model's properties.
    ///
    /// This is needed to prevent the current state from interfering with
    /// future uses of the `FeatureEditor` view.
    private func resetProperties() {
        rootFeatureForm = nil
        presentedFeatureForm = nil
        snapSettingsSheetIsPresented = false
        viewpointGeometry = nil
        
        stopGeometryEditing()
        
        loadResult = nil
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
            
            // Snapping is enabled by default to simplify the `SnapSettingsView` UI.
            snapSettings.isEnabled = true
        } catch {
            Logger.featureEditor.error(
                "Error syncing snap source settings: \(error.localizedDescription)"
            )
        }
    }
    
    /// Updates the form's feature geometry using the geometry editor's current
    /// geometry to update possible geometry-dependent form elements.
    func updateFormGeometry() async throws {
        guard geometryEditorIsStarted else { return }
        
        // Uses initialGeometry if the geometry editor has no edits to prevent
        // an empty geometry from being used when the geometry editor was
        // started using a geometryType (when feature.geometry is nil).
        let geometry = geometryEditorCanUndo ? geometryEditorGeometry : initialGeometry
        try await setFormGeometry(to: geometry)
    }
    
    /// Sets the form's feature geometry and reevaluates expressions to update
    /// possible geometry-dependent form elements.
    /// - Parameter geometry: The new geometry to set on the feature.
    private func setFormGeometry(to geometry: Geometry?) async throws {
        guard let featureForm = presentedFeatureForm ?? rootFeatureForm,
              featureForm.feature.geometry != geometry else {
            return
        }
        
        featureForm.feature.geometry = geometry
        try await featureForm.evaluateExpressions()
    }
    
    /// Performs setup needed for geometry editing and starts the geometry editor if applicable.
    private func setUpGeometryEditing() async {
        loadResult = await Result { @MainActor in
            guard let feature else { return }
            
            // Loads the feature so canUpdateGeometry can be accessed. It is always
            // false otherwise.
            try await feature.retryLoad()
            guard feature.canUpdateGeometry else { return }
            
            // Loads the feature's table so geometryType can be accessed and
            // snap rules can be created.
            try await feature.table?.retryLoad()
            
            do {
                snapRules = try await feature.snapRules
            } catch {
                snapRules = nil
                Logger.featureEditor.error(
                    "Failed to create snap rules: \(error.localizedDescription)"
                )
            }
            syncSnapSourceSettings()
            
            startGeometryEditor()
        }
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
        initialGeometry = feature.geometry
    }
    
    /// Stops the geometry editor and resets the related model properties.
    private func stopGeometryEditing() {
        geometryEditor.stop()
        geometryEditorCanUndo = false
        geometryEditorGeometry = nil
        geometryEditorIsStarted = false
        initialGeometry = nil
        snapRules = nil
    }
}

private extension ArcGISFeature {
    /// The snap rules for the feature, created from the feature's utility network, if applicable.
    var snapRules: SnapRules? {
        get async throws {
            guard let table else { return nil }
            
            let utilityNetworks = try await table.utilityNetworks
            await utilityNetworks.load()
            
            // Tries to find the feature's utility network by creating an
            // utility element and then uses both to create snap rules.
            for utilityNetwork in utilityNetworks {
                if let element = utilityNetwork.makeElement(arcGISFeature: self) {
                    return try await .rules(for: utilityNetwork, assetType: element.assetType)
                }
            }
            
            // If an utility element cannot be created, tries to find the
            // utility network that contains the feature's table and then
            // uses it and the feature's attributes to create snap rules.
            for utilityNetwork in utilityNetworks {
                if let definition = utilityNetwork.definition,
                   definition.networkSources.contains(where: { $0.featureTable === table }) {
                    return try await .rules(
                        for: utilityNetwork,
                        featureTable: table,
                        attributes: attributes
                    )
                }
            }
            
            return nil
        }
    }
}

private extension FeatureTable {
    /// The utility networks of the table's geodatabase, if applicable.
    var utilityNetworks: [UtilityNetwork] {
        get async throws {
            switch self {
            case let serviceFeatureTable as ServiceFeatureTable:
                guard let serviceGeodatabase = serviceFeatureTable.serviceGeodatabase else {
                    return []
                }
                try await serviceGeodatabase.retryLoad()
                
                guard let utilityNetwork = serviceGeodatabase.utilityNetwork else {
                    return []
                }
                return [utilityNetwork]
            case let geodatabaseFeatureTable as GeodatabaseFeatureTable:
                guard let geodatabase = geodatabaseFeatureTable.geodatabase else {
                    return []
                }
                try await geodatabase.retryLoad()
                
                return geodatabase.utilityNetworks
            default:
                return []
            }
        }
    }
}
