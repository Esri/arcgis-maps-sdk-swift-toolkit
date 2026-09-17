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

/// A view model for adding features using shared templates.
@MainActor
@Observable
final class FeatureAddingModel {
    /// The layer template groups from the map.
    private(set) var groups: [LayerTemplateGroup] = []
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
        featureEditorModel.stopAddingFeatures()
    }
}

private extension Map {
    /// The layer template groups from the map's operational layers and tables.
    var layerTemplateGroups: [LayerTemplateGroup] {
        get async throws {
            struct HashableSharedTemplateSource: Hashable {
                let base: any SharedTemplateSource & Loadable
                
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
            
            var featureTableArrays: [HashableSharedTemplateSource: [ArcGISFeatureTable]] = [:]
            
            func addTable(_ table: ArcGISFeatureTable) async throws {
                try await table.load()
                
                guard table.hasGeometry,
                      table.isEditable,
                      table.canAddFeature,
                      let sharedTemplateSource = table.sharedTemplateSource else {
                    return
                }
                
                let key = HashableSharedTemplateSource(sharedTemplateSource)
                featureTableArrays[key, default: []].append(table)
            }
            
            func addTables(from layers: [Layer]) async throws {
                for layer in layers {
                    try await layer.load()
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
            
            try await addTables(from: operationalLayers)
            for case let table as ArcGISFeatureTable in tables {
                try await addTable(table)
            }
            
            var layerTemplateGroups: [LayerTemplateGroup] = []
            for (key, tables) in featureTableArrays {
                let sharedTemplateSource = key.base
                try await sharedTemplateSource.load()
                let tablesKeyedByLayerID = Dictionary(
                    uniqueKeysWithValues: tables.lazy.map { ($0.serviceLayerID, $0) }
                )
                let sharedTemplates = try await sharedTemplateSource
                    .querySharedTemplates(using: nil)
                for (layerID, sharedTemplates) in sharedTemplates {
                    guard let table = tablesKeyedByLayerID[layerID] else { continue }
                    let group = LayerTemplateGroup(
                        name: table.displayName,
                        layerTemplates: sharedTemplates
                            .map { .init(layerID: layerID, sharedTemplate: $0) }
                            .sorted(by: { $0.name < $1.name })
                    )
                    layerTemplateGroups.append(group)
                }
            }
            dump(layerTemplateGroups.sorted(by: { $0.name < $1.name }))
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
