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
import Foundation
import Observation

/// A view model for adding features using shared templates.
@MainActor
@Observable
final class FeatureAddingModel {
    /// The state of geometry construction for the selected template.
    enum GeometryConstructionState: Equatable {
        case loading
        case editing
        case saving
        case noSupportedTools
        case error(localizedDescription: String)
    }

    /// The layer template groups from the map.
    private(set) var groups: [LayerTemplateGroup] = []
    /// The form for the first feature created from a selected template.
    var featureForm: FeatureForm?
    /// A Boolean value indicating whether the adding inspector is presented.
    var inspectorIsPresented = true
    /// The navigation path through the template picker.
    var navigationPath: [LayerTemplate] = []
    /// The state of geometry construction for the selected template.
    var geometryConstructionState: GeometryConstructionState = .loading
    /// The identifier of the template currently being used for geometry construction.
    private var geometryConstructionTemplateID: UUID?
    /// A Boolean value indicating whether the parent feature editor inspector is presented.
    var isPresented: Bool {
        get { featureEditorModel.isPresented }
        set {
            guard !newValue else { return }
            stop()
        }
    }
    /// The feature editor model that owns this model.
    private unowned let featureEditorModel: FeatureEditorModel
    
    /// Creates an instance with the given feature editor model.
    /// - Parameter featureEditorModel: A feature editor model.
    init(featureEditorModel: FeatureEditorModel) {
        self.featureEditorModel = featureEditorModel
    }
    
    /// Adds shared templates from all operational layers of the map to this
    /// model.
    /// - Parameter map: The map from whose operational layers the shared
    /// templates should be populated.
    func populateSharedTemplates(from map: Map?) async throws {
        if let map {
            try await map.load()
            groups = try await map.layerTemplateGroups
        } else {
            groups = []
        }
    }
    
    /// Stops adding features.
    func stop() {
        featureForm = nil
        featureEditorModel.stopAddingFeatures()
    }

    /// Prepares the template picker for a new feature-adding session.
    func start() {
        featureForm = nil
        inspectorIsPresented = true
        navigationPath = []
        geometryConstructionState = .loading
        geometryConstructionTemplateID = nil
    }

    /// Shows the template picker and stops the current geometry construction session.
    func showTemplatePicker() {
        featureEditorModel.geometryEditorModel.stop()
        navigationPath = []
        geometryConstructionState = .loading
        geometryConstructionTemplateID = nil
        inspectorIsPresented = true
    }

    /// Shows the geometry construction saving progress for the selected template.
    func saveGeometryConstruction() {
        geometryConstructionState = .saving
        inspectorIsPresented = true
    }

    /// Hides the inspector while geometry construction continues in the toolbar.
    func hideInspectorForGeometryConstruction() {
        inspectorIsPresented = false
    }

    /// Starts geometry construction for a newly selected template.
    /// - Parameter layerTemplate: The template selected in the template picker.
    /// - Returns: A Boolean value indicating whether geometry construction should load.
    func beginGeometryConstruction(for layerTemplate: LayerTemplate) -> Bool {
        guard geometryConstructionTemplateID != layerTemplate.id else { return false }
        geometryConstructionTemplateID = layerTemplate.id
        geometryConstructionState = .loading
        return true
    }

    /// A Boolean value indicating whether the active geometry editor has edits.
    var hasGeometryEdits: Bool {
        let geometryEditorModel = featureEditorModel.geometryEditorModel
        let initialGeometry = geometryEditorModel.initialGeometry
        guard geometryEditorModel.isStarted,
              let currentGeometry = geometryEditorModel.geometry,
              currentGeometry != initialGeometry,
              initialGeometry != nil || !currentGeometry.isEmpty else {
            return false
        }
        return true
    }
}

private extension Map {
    /// The layer template groups from the map's operational layers and tables.
    var layerTemplateGroups: [LayerTemplateGroup] {
        get async throws {
            /// A hashable shared template source.
            /// - Note: Needed because `SharedTemplateSource` is not hashable.
            struct HashableSharedTemplateSource: Hashable {
                /// The shared template source wrapped by this instance.
                let base: any SharedTemplateSource & Loadable
                
                /// Creates an instance with the given shared template source.
                init(_ base: any SharedTemplateSource & Loadable) {
                    self.base = base
                }
                
                static func == (lhs: Self, rhs: Self) -> Bool {
                    return lhs.base === rhs.base
                }
                
                func hash(into hasher: inout Hasher) {
                    hasher.combine(ObjectIdentifier(base))
                }
            }
            
            /// A dictionary of feature tables, keyed by service layer
            /// identifier, keyed by shared template source.
            ///
            /// This helps to:
            /// 1. Only query for templates once per source
            /// 2. Only include templates that are a part of the map.
            var featureTablesBySharedTemplateSource: [HashableSharedTemplateSource: [Int: ArcGISFeatureTable]] = [:]
            
            func addTable(_ table: ArcGISFeatureTable) async throws {
                try await table.load()
                
                guard table.isEditable,
                      table.canAddFeature,
                      let sharedTemplateSource = table.sharedTemplateSource else {
                    return
                }
                
                let key = HashableSharedTemplateSource(sharedTemplateSource)
                featureTablesBySharedTemplateSource[key, default: [:]][table.serviceLayerID] = table
            }
            
            func addTables(from layers: [Layer]) async throws {
                for layer in layers {
                    switch layer {
                    case let groupLayer as GroupLayer:
                        try await addTables(from: groupLayer.layers)
                    case let featureLayer as FeatureLayer:
                        if let featureTable = featureLayer.featureTable as? ArcGISFeatureTable {
                            try await addTable(featureTable)
                        }
                    default:
                        continue
                    }
                }
            }
            
            try await load()
            
            // Record all the feature table referenced by the map.
            
            try await addTables(from: operationalLayers)
            for case let table as ArcGISFeatureTable in tables {
                try await addTable(table)
            }
            
            // Iterate over referenced feature table, query for shared
            // templates, and create groups.
            
            var layerTemplateGroups: [LayerTemplateGroup] = []
            for (key, featureTablesByLayerID) in featureTablesBySharedTemplateSource {
                let sharedTemplateSource = key.base
                try await sharedTemplateSource.load()
                let parameters = SharedTemplateQueryParameters()
                parameters.sourceType = .layer
                parameters.addLayerIDs(featureTablesByLayerID.keys)
                let sharedTemplates = try await sharedTemplateSource
                    .querySharedTemplates(using: parameters)
                for (layerID, sharedTemplates) in sharedTemplates {
                    guard let table = featureTablesByLayerID[layerID] else { continue }
                    let group = LayerTemplateGroup(
                        name: table.displayName,
                        layerTemplates: sharedTemplates.lazy
                            .map { .init(table: table, sharedTemplate: $0) }
                            .sorted(by: { $0.name < $1.name })
                    )
                    layerTemplateGroups.append(group)
                }
            }
            return layerTemplateGroups.sorted(by: { $0.name < $1.name })
        }
    }
}

private extension ArcGISFeatureTable {
    /// The shared template source for this table.
    var sharedTemplateSource: (any SharedTemplateSource & Loadable)? {
        return switch self {
        case let geodatabaseFeatureTable as GeodatabaseFeatureTable:
            geodatabaseFeatureTable.geodatabase
        case let serviceFeatureTable as ServiceFeatureTable:
            serviceFeatureTable.serviceGeodatabase
        default:
            nil
        }
    }
}
