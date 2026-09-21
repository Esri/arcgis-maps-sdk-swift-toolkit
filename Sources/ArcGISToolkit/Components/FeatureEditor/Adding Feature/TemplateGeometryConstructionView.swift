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
import SwiftUI

/// A view for creating a geometry for a template.
struct TemplateGeometryConstructionView: View {
    /// The shared feature editor model.
    @Environment(FeatureEditorModel.self) private var model
    
    /// The selected layer template that will be used to construct the geometry.
    let layerTemplate: LayerTemplate
    /// The action to perform after a feature form is created.
    let onFeatureFormCreated: (FeatureForm) -> Void
    
    @State private var geometry: Geometry?
    
    var body: some View {
        Group {
            switch model.featureAddingModel.geometryConstructionState {
            case .loading:
                ProgressView {
                    Text(
                        "Loading geometry construction tools",
                        bundle: .toolkitModule,
                        comment: "A label shown while the construction tools for a feature template are loading."
                    )
                }
            case .saving:
                ProgressView {
                    Text(
                        "Creating features",
                        bundle: .toolkitModule,
                        comment: "A label shown while a new feature is being created."
                    )
                }
            case .noSupportedTools:
                ContentUnavailableView {
                    Label {
                        Text(
                            "Geometry Construction Not Supported",
                            bundle: .toolkitModule,
                            comment: "The title shown when a feature template has no supported geometry construction tools."
                        )
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                } description: {
                    Text(
                        "Creating a geometry for this template is not supported.",
                        bundle: .toolkitModule,
                        comment: "A message explaining that geometry cannot be constructed for a feature template."
                    )
                }
            case .error(let localizedDescription):
                ContentUnavailableView {
                    Label {
                        Text(
                            "Feature Creation Failed",
                            bundle: .toolkitModule,
                            comment: "The title shown when feature creation from a template failed."
                        )
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                } description: {
                    Text(localizedDescription)
                } actions: {
                    Button {
                        startGeometryEditor(geometry: geometry.take())
                        model.featureAddingModel.geometryConstructionState = .editing
                        model.featureAddingModel.hideInspectorForGeometryConstruction()
                    } label: {
                        Text.cancel
                    }
                }
            case .editing:
                EmptyView()
            }
        }
        .navigationTitle(layerTemplate.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard model.featureAddingModel.beginGeometryConstruction(for: layerTemplate) else {
                return
            }
            await setUpGeometryEditor()
        }
        .task(id: model.featureAddingModel.geometryConstructionState) {
            do {
                switch model.featureAddingModel.geometryConstructionState {
                case .saving:
                    try await save()
                default:
                    break
                }
            } catch {
                model.featureAddingModel.geometryConstructionState = .error(
                    localizedDescription: error.localizedDescription
                )
            }
        }
    }
    
    private func startGeometryEditor(geometry: Geometry? = nil) {
        if let geometry = geometry {
            model.geometryEditorModel.start(withInitial: geometry)
        } else if let geometryType = layerTemplate.featureTable?.geometryType {
            model.geometryEditorModel.start(withType: geometryType)
        } else {
            model.featureAddingModel.geometryConstructionState = .noSupportedTools
        }
    }
    
    private func setUpGeometryEditor() async {
        do {
            let template = layerTemplate.sharedTemplate
            try await template.load()
            
            if layerTemplate.featureTable?.hasGeometry == false {
                try await createFeature(with: nil)
                return
            }
            
            let applicableConstructionTools = GeometryConstructionTool.Kind.supportedCases.filter {
                template.isTool($0, applicableForLayerWithID: layerTemplate.layerID)
            }
            
            guard !applicableConstructionTools.isEmpty else {
                model.featureAddingModel.geometryConstructionState = .noSupportedTools
                return
            }
            
            let defaultConstructionTool = template
                .defaultConstructionTool(forLayerWithID: layerTemplate.layerID)?
                .kind
            let tools = applicableConstructionTools.compactMap(\.tool)
            let selectedTool = defaultConstructionTool?.tool
            
            model.geometryEditorModel.setSelectableTools(tools, selectedTool: selectedTool)
            startGeometryEditor()
            guard model.featureAddingModel.geometryConstructionState == .loading else { return }
            withAnimation {
                model.featureAddingModel.geometryConstructionState = .editing
            }
            model.featureAddingModel.hideInspectorForGeometryConstruction()
        } catch {
            model.featureAddingModel.geometryConstructionState = .error(
                localizedDescription: error.localizedDescription
            )
        }
    }
    
    private func save() async throws {
        geometry = model.geometryEditorModel.geometry
        model.geometryEditorModel.stop(resetTools: false)
        
        try await createFeature(with: geometry)
        model.geometryEditorModel.stop()
    }
    
    private func createFeature(with geometry: Geometry?) async throws {
        let source = layerTemplate.sharedTemplate.source
        let template = layerTemplate.sharedTemplate
        let featureSet = try await source.makeFeatures(sharedTemplate: template, geometry: geometry)
        try await source.addFeatures(using: featureSet)
        
        guard let firstFeature = featureSet.features.first else { return }
        onFeatureFormCreated(FeatureForm(feature: firstFeature))
    }
}

private extension GeometryConstructionTool.Kind {
    static var supportedCases: [Self] {
        [
            .circle,
            .ellipse,
            .freehand,
            .line,
            .multipoint,
            .point,
            .polygon,
            .rectangle
        ]
    }
    
    var tool: GeometryEditorModel.Tool? {
        switch self {
        case .freehand:
            GeometryEditorModel.Tool(
                label: label,
                systemImage: "scribble",
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            ) {
                FreehandTool()
            }
        case .circle:
            GeometryEditorModel.Tool(
                label: label,
                systemImage: "circle",
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            ) {
                let tool = ShapeTool(kind: .ellipse)
                tool.configuration.scaleMode = .uniform
                return tool
            }
        case .ellipse:
            GeometryEditorModel.Tool(
                label: label,
                systemImage: "circle",
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            ) {
                ShapeTool(kind: .ellipse)
            }
        case .rectangle:
            GeometryEditorModel.Tool(
                label: label,
                systemImage: "rectangle",
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            ) {
                ShapeTool(kind: .rectangle)
            }
        case .line, .multipoint, .point, .polygon:
            GeometryEditorModel.Tool(
                label: label,
                systemImage: GeometryEditorModel.Tool.vertex.systemImage,
                supportedGeometryTypes: [
                    Multipoint.self,
                    Point.self,
                    Polygon.self,
                    Polyline.self
                ]
            ) {
                VertexTool()
            }
        default:
            fatalError("Unsupported GeometryConstructionTool.Kind: \(self)")
        }
    }
    
    var label: String {
        switch self {
        case .circle: "Circle"
        case .ellipse: "Ellipse"
        case .freehand: "Freehand"
        case .line: "Line"
        case .multipoint: "Multipoint"
        case .point: "Point"
        case .polygon: "Polygon"
        case .rectangle: "Rectangle"
        default:
            fatalError("Unsupported GeometryConstructionTool.Kind: \(self)")
        }
    }
}
