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
    func populateSharedTemplates(from map: Map?) async {
        if let map {
            try? await map.load()
            groups = await map.layerTemplateGroups
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
    /// The layer template groups from the map's operational layers.
    var layerTemplateGroups: [LayerTemplateGroup] {
        get async {
            await withTaskGroup(of: Optional<LayerTemplateGroup>.self) { taskGroup in
                for layer in operationalLayers {
                    taskGroup.addTask {
                        guard let (tableName, layerID, templates) = await layer.sharedTemplates,
                              !templates.isEmpty else {
                            return nil
                        }
                        let layerTemplates = templates.lazy
                            .map { LayerTemplate(layerID: layerID, sharedTemplate: $0) }
                            .sorted(by: { $0.name < $1.name })
                        return LayerTemplateGroup(name: tableName, layerTemplates: layerTemplates)
                    }
                }
                
                var groupItems: [LayerTemplateGroup] = []
                for await group in taskGroup {
                    guard let group else { continue }
                    groupItems.append(group)
                }
                
                return groupItems.sorted { $0.name < $1.name }
            }
        }
    }
}

private extension Layer {
    /// The layer's name, ID, and shared templates when it supports adding features.
    var sharedTemplates: (String, Int, [SharedTemplate])? {
        get async {
            guard let self = self as? FeatureLayer else { return nil }
            
            try? await self.load()
            
            guard let table = self.featureTable as? ServiceFeatureTable else {
                return nil
            }
            
            try? await table.load()
            
            guard table.hasGeometry,
                  table.isEditable,
                  table.canAddFeature,
                  let geodatabase = table.serviceGeodatabase else {
                return nil
            }
            
            try? await geodatabase.load()
            
            do {
                let serviceLayerUD = table.serviceLayerID
                let parameters = SharedTemplateQueryParameters()
                parameters.addLayerID(serviceLayerUD)
                return try await geodatabase.querySharedTemplates().first
                    .map { (table.displayName, $0, $1) }
            } catch {
                return nil
            }
        }
    }
}
