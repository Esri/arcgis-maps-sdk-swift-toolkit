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
    /// The currently selected layer template.
    var selectedLayerTemplate: LayerTemplate?
    /// The form for the newly added feature.
    private(set) var featureForm: FeatureForm?
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
        if geometryConstructionState != .stopped {
            geometryConstructionState = .stopped
        }
        if featureForm != nil {
            featureForm = nil
        }
        featureEditorModel.stopAddingFeatures()
    }
    
    // MARK: Geometry Construction
    
    /// The kinds of errors that can be thrown when geometry
    /// construction fails.
    enum GeometryConstructionError: Error {
        case templateUnavailable(any Error)
        case noSupportedTools
        case featureCreationFailed(any Error)
        case noFeatureForm
    }
    
    /// The possible states of geometry construction for the selected template.
    enum GeometryConstructionState: Equatable {
        case stopped
        case loading
        case editing
        case saving(Geometry)
        case cancelling
        case failed(GeometryConstructionError)
    }
    
    /// The state of geometry construction.
    private(set) var geometryConstructionState: GeometryConstructionState = .stopped
    
    /// The geometry editor model used for geometry editing.
    private var geometryEditorModel: GeometryEditorModel {
        featureEditorModel.geometryEditorModel
    }
    
    /// Starts geometry construction for a new feature using the given layer
    /// template.
    /// - Parameter layerTemplate: The template for the new feature.
    func startConstruction(using layerTemplate: LayerTemplate) async {
        precondition(geometryConstructionState == .stopped)
        do throws(GeometryConstructionError) {
            if layerTemplate.featureTable.hasGeometry {
                geometryConstructionState = .loading
                
                let constructionToolKinds: [GeometryConstructionTool.Kind]
                do {
                    constructionToolKinds = try await layerTemplate.constructionToolKinds
                } catch {
                    throw .templateUnavailable(error)
                }
                
                if constructionToolKinds.isEmpty {
                    throw .noSupportedTools
                }
                
                let geometryEditorModel = featureEditorModel.geometryEditorModel
                
                let defaultConstructionTool = layerTemplate.defaultConstructionTool?.kind
                let tools = constructionToolKinds.compactMap(FeatureEditorGeometryTool.init)
                let selectedTool = defaultConstructionTool.flatMap(FeatureEditorGeometryTool.init)
                geometryEditorModel.setConstructionTools(
                    tools,
                    selection: selectedTool ?? tools.first ?? .vertex
                )
                
                geometryEditorModel.start(withType: layerTemplate.featureTable.geometryType!)
                
                geometryConstructionState = .editing
            } else {
                let featureForm = try await makeFeatureForm(
                    layerTemplate: layerTemplate
                )
                self.featureForm = featureForm
            }
        } catch {
            geometryConstructionState = .failed(error)
        }
    }
    
    /// Saves the constructed geometry.
    /// - Precondition: `geometryConstructionState == .editing`
    func saveConstructedGeometry() {
        precondition(geometryConstructionState == .editing)
        guard let geometry = geometryEditorModel.geometryEditor.geometry else {
            preconditionFailure("No constructed geometry to save")
        }
        geometryEditorModel.stop()
        geometryConstructionState = .saving(geometry)
    }
    
    /// Saves the constructed geometry to a feature form with the given layer
    /// template and returns the model to a stopped state.
    /// - Parameters:
    ///   - geometry: The geometry to save.
    ///   - layerTemplate: The layer template for the new feature.
    func finishSavingConstruction(
        _ geometry: Geometry,
        layerTemplate: LayerTemplate
    ) async {
        do {
            let featureForm = try await makeFeatureForm(
                layerTemplate: layerTemplate,
                geometry: geometry
            )
            self.featureForm = featureForm
            geometryConstructionState = .stopped
        } catch {
            geometryConstructionState = .failed(error)
        }
    }
    
    /// Cancels constructing a geometry.
    /// - Precondition: `geometryConstructionState == .editing`
    func cancelConstruction() {
        precondition(geometryConstructionState == .editing)
        geometryEditorModel.stop()
        geometryConstructionState = .cancelling
    }
    
    /// Returns the model to a stopped state..
    /// - Precondition: `geometryConstructionState == .editing`
    func finishCancellingConstruction() {
        precondition(geometryConstructionState == .cancelling)
        geometryConstructionState = .stopped
    }
}

private extension FeatureAddingModel {
    func makeFeatureForm(
        layerTemplate: LayerTemplate,
        geometry: Geometry? = nil
    ) async throws(GeometryConstructionError) -> FeatureForm {
        let source = layerTemplate.sharedTemplate.source
        let featureSet: SharedTemplateFeatureCreationSet
        do {
            featureSet = try await layerTemplate.makeFeatures(geometry: geometry)
            try await source.addFeatures(using: featureSet)
        } catch {
            throw .featureCreationFailed(error)
        }
        if let feature = featureSet.features.first {
            return FeatureForm(feature: feature)
        } else {
            throw .noFeatureForm
        }
    }
}

extension FeatureAddingModel.GeometryConstructionError: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return switch (lhs, rhs) {
        case (.noSupportedTools, .noSupportedTools):
            true
        case (.featureCreationFailed(let lhsError), .featureCreationFailed(let rhsError)):
            // Not perfect, but good enough. The state shouldn't ever go from
            // 'featureCreationFailed' to 'featureCreationFailed'.
            String(describing: lhsError) == String(describing: rhsError)
        default:
            false
        }
    }
}

private extension FeatureEditorGeometryTool {
    init?(kind: GeometryConstructionTool.Kind) {
        let tool: Self? = switch kind {
        case .freehand: .freehand
        case .ellipse: .shape(kind: .ellipse)
        case .rectangle: .shape(kind: .rectangle)
        default: nil
        }
        guard let tool else { return nil }
        self = tool
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
                    guard let featureTable = featureTablesByLayerID[layerID] else { continue }
                    let group = LayerTemplateGroup(
                        name: featureTable.displayName,
                        layerTemplates: sharedTemplates.lazy
                            .map { .init(featureTable: featureTable, sharedTemplate: $0) }
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
