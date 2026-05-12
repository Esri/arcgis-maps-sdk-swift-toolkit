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

// TODO: Add discard edits alert for navigation back button
struct GeometryConstructionToolPicker: View {
    let templateItem: TemplatePickerItem
    let geometryEditor: GeometryEditor
    
    @Environment(\.navigationPath) private var navigationPath
    @Environment(\.templateAllowedTools) private var templateAllowedTools
    
    @State private var applicableToolKinds: [GeometryConstructionTool.Kind]?
    @State private var geometry: Geometry?
    @State private var isSaving = false
    @State private var lastGeometry: Geometry?
    @State private var selectedToolKind: GeometryConstructionTool.Kind?
    
    var body: some View {
        Form {
            if let applicableToolKinds {
                Picker("Tools", selection: $selectedToolKind) {
                    ForEach(applicableToolKinds, id: \.self) { toolKind in
                        Label(toolKind.label, image: toolKind.calciteIcon)
                            .tag(toolKind as GeometryConstructionTool.Kind?)
                            .selectionDisabled(!toolKind.isSupported)
                    }
                }
                .pickerStyle(.inline)
                .task {
                    for await geometry in geometryEditor.$geometry {
                        self.geometry = geometry
                    }
                }
                .onChange(of: selectedToolKind) {
                    guard let selectedToolKind else { return }
                    edit(item: templateItem, with: selectedToolKind)
                }
            } else {
                ProgressView("Loading tools")
                    .frame(maxWidth: .infinity)
                    .task(setUp)
            }
        }
        .navigationDestination(for: [FeatureFormItem].self) { featureFormItems in
            CreatedFeaturesList(featureFormItems: featureFormItems)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back", systemImage: "chevron.backward") {
                    navigationPath?.wrappedValue.removeLast()
                }
            }
            
            ToolbarItemGroup(placement: .topBarTrailing) {
                SnapSettingsButton(settings: geometryEditor.snapSettings)
                    .disabled(applicableToolKinds == nil)
                
                Button("Save", systemImage: "checkmark") {
                    isSaving = true
                }
                .tint(.accentColor)
                .disabled(isSaving || geometry?.sketchIsValid != true)
                .task(id: isSaving) {
                    guard isSaving else { return }
                    defer { isSaving = false }
                    
                    await save(geometry: geometryEditor.stop())
                }
            }
        }
        .overlay {
            if isSaving, #available(iOS 26, *) {
                ProgressView("Saving")
                    .padding()
                    .glassEffect()
                    .shadow(radius: 1)
            }
        }
        .disabled(isSaving)
        .navigationTitle("Create Features")
        .onDisappear {
            // Stops the geometry editor when navigating back from this view.
            geometryEditor.stop()
        }
    }
    
    private func setUp() async {
        do {
            let template = templateItem.template
            try await template.load()
            
            // TODO: Fail if no table because can't start geometry editor.
            let templateTable = template.source.featureTable(withLayerID: templateItem.layerID)
            try await templateTable?.load()
            
            applicableToolKinds = GeometryConstructionTool.Kind.allCases.filter {
                template.isTool($0, applicableForLayerWithID: templateItem.layerID)
            }
            
            let defaultTool = template.defaultConstructionTool(forLayerWithID: templateItem.layerID)
            selectedToolKind = defaultTool?.kind
            
            //            print(template.options(for: defaultTool!))
            
            guard let selectedToolKind else { return }
            edit(item: templateItem, with: selectedToolKind)
            
            if _DebugSettings.addTemplateGeometry {
                _DebugSettings.addTemplateGeometry = false
                let geometryData = Data(_DebugSettings.templateGeometry.utf8)
                let geometry = try! Polyline.fromJSON(geometryData)
                await save(geometry: geometry)
            }
        } catch {
            print("Error setting up tools: \(error)")
        }
    }
    
    private func save(geometry: Geometry?) async {
        guard let geometry else { return }
        
        do {
            let template = templateItem.template
            let source = template.source
            
            let featureSet = try await source.makeFeatures(
                sharedTemplate: template,
                geometry: geometry
            )
            try await source.addFeatures(using: featureSet)
            
            let featureFormItems = makeFeatureFormItems(
                templateItem: templateItem,
                featureSet: featureSet
            )
            lastGeometry = geometry
            navigationPath?.wrappedValue.append(featureFormItems)
        } catch {
            print("Error saving features: \(error)")
        }
    }
    
    private func edit(item: TemplatePickerItem, with toolKind: GeometryConstructionTool.Kind) {
        // Starts the geometry editor with the last geometry when the
        // CreatedFeaturesList back button is pressed.
        if let lastGeometry {
            self.lastGeometry = nil
            geometryEditor.start(withInitial: lastGeometry)
        } else if let table = item.template.source.featureTable(withLayerID: item.layerID) {
            guard let geometryType = table.geometryType else { return }
            geometryEditor.start(withType: geometryType)
        } else {
            fatalError("TODO: Handle no table geometry type")
        }
        
        templateAllowedTools?.wrappedValue = Set(toolKind.validToolbarTools)
    }
    
    private func makeFeatureFormItems(
        templateItem: TemplatePickerItem,
        featureSet: SharedTemplateFeatureCreationSet
    ) -> [FeatureFormItem] {
        return if featureSet.features.count == 1 {
            [FeatureFormItem(feature: featureSet.features.first!, templateItem: templateItem)]
        } else if let definition = templateItem.template.definition as? GroupTemplateDefinition {
            definition.parts.enumerated().reduce(into: []) { result, part in
                let template = part.element.template
                if part.offset < featureSet.features.count, let layerID = template.layerIDs.first {
                    let templateItem = TemplatePickerItem(template, layerID: layerID)
                    let feature = featureSet.features[part.offset]
                    result.append(FeatureFormItem(feature: feature, templateItem: templateItem))
                }
            }
        } else {
            []
        }
    }
}

// MARK: - Extensions

private extension GeometryConstructionTool.Kind {
    static var allCases: [Self] {
        [
            .autoCompleteFreehandPolygon,
            .autoCompletePolygon,
            .circle,
            .ellipse,
            .freehand,
            .line,
            .multipoint,
            .point,
            .pointAlongLine,
            .pointAndRotation,
            .pointAtEndOfLine,
            .polygon,
            .radial,
            .rectangle,
            .regularPolygon,
            .regularPolyline,
            .rightAnglePolygon,
            .rightAnglePolyline,
            .split,
            .streamingPolygon,
            .streamingPolyline,
            .trace,
            .twoPointLine,
        ]
    }
    
    var label: String {
        switch self {
        case .autoCompleteFreehandPolygon: "Auto Complete Freehand Polygon"
        case .autoCompletePolygon: "Auto Complete Polygon"
        case .circle: "Circle"
        case .ellipse: "Ellipse"
        case .freehand: "Freehand"
        case .line: "Line"
        case .multipoint: "Multipoint"
        case .point: "Point"
        case .pointAlongLine: "Point Along Line"
        case .pointAndRotation: "Point and Rotation"
        case .pointAtEndOfLine: "Point at End of Line"
        case .polygon: "Polygon"
        case .radial: "Radial"
        case .rectangle: "Rectangle"
        case .regularPolygon: "Regular Polygon"
        case .regularPolyline: "Regular Polyline"
        case .rightAnglePolygon: "Right Angle Polygon"
        case .rightAnglePolyline: "Right Angle Polyline"
        case .split: "Split"
        case .streamingPolygon: "Streaming Polygon"
        case .streamingPolyline: "Streaming Polyline"
        case .trace: "Trace"
        case .twoPointLine: "Two Point Line"
        @unknown default: fatalError()
        }
    }
    
    var calciteIcon: String {
        switch self {
        case .autoCompleteFreehandPolygon: "lasso"
        case .autoCompletePolygon: "polygon-line-check"
        case .circle: "circle"
        case .ellipse: "ellipse"
        case .freehand: "freehand"
        case .line: "line"
        case .multipoint: "nodes-unlink"
        case .point: "point"
        case .pointAlongLine: "connection-middle"
        case .pointAndRotation: "rotate"
        case .pointAtEndOfLine: "connection-end-right"
        case .polygon: "polygon-vertices"
        case .radial: "relative-direction"
        case .rectangle: "rectangle"
        case .regularPolygon: "hexagon-inset-large"
        case .regularPolyline: "hexagon"
        case .rightAnglePolygon: "rectangle-plus"
        case .rightAnglePolyline: "right-angle"
        case .split: "split-geometry"
        case .streamingPolygon: "lasso-select"
        case .streamingPolyline: "trace-path"
        case .trace: "trace"
        case .twoPointLine: "connection-to-connection"
        @unknown default: fatalError()
        }
    }
    
    var validToolbarTools: [GeometryEditorToolbar.Tool] {
        switch self {
        case .circle:
            let circleShapeTool = ShapeTool(kind: .ellipse)
            circleShapeTool.configuration.scaleMode = .uniform
            
            let circleToolbarTool = GeometryEditorToolbar.CustomTool(
                circleShapeTool,
                label: "Circle",
                systemImage: "circle",
                supportedGeometryTypes: [Polygon.self, Polyline.self]
            )
            
            return [.custom(circleToolbarTool)]
        case .ellipse:
            return [.shape(kind: .ellipse)]
        case .freehand:
            return [.freehand]
        case .line, .polygon:
            return GeometryEditorToolbar.Tool.vertexTools + GeometryEditorToolbar.Tool.shapeTools
        case .point, .multipoint:
            return GeometryEditorToolbar.Tool.vertexTools
        case .rectangle:
            return [.shape(kind: .rectangle)]
        default:
            return []
        }
    }
    
    var isSupported: Bool {
        let supportedCases: Set<Self> = [
            .circle,
            .ellipse,
            .freehand,
            .line,
            .multipoint,
            .point,
            .polygon,
            .rectangle
        ]
        return supportedCases.contains(self)
    }
}

private extension GeometryEditorToolbar.Tool {
    static var vertexTools: [Self] {
        [.vertex, .vertexReticle, .programmaticReticle]
    }
    
    static var shapeTools: [Self] {
        ShapeTool.Kind.allCases.map(Self.shape(kind:))
    }
}

private extension ShapeTool.Kind {
    static var allCases: [Self] {
        [.arrow, .ellipse, .rectangle, .triangle]
    }
}
