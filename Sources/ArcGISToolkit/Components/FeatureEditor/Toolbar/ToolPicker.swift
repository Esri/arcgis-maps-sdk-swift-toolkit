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

/// A control for picking a geometry editing tool.
struct ToolPicker: View {
    /// The model for the parent feature editor containing the geometry editor.
    @Environment(FeatureEditorModel.self) private var featureEditorModel
    
    var body: some View {
        @Bindable var geometryEditorModel = featureEditorModel.geometryEditorModel
        let title = LocalizedStringResource(
            "Tool",
            bundle: .toolkit,
            comment: "A label for a control to pick a geometry editor tool."
        )
        Menu(title, systemImage: geometryEditorModel.selectedTool.systemImage) {
            Picker(title, selection: $geometryEditorModel.selectedTool) {
                ForEach(geometryEditorModel.selectableTools, id: \.self) { tool in
                    Label(tool.label, systemImage: tool.systemImage)
                }
            }
        }
        .accessibilityIdentifier("Tool")
        .animation(.default, value: geometryEditorModel.selectedTool)
    }
}

#Preview {
    @Previewable @State var featureEditorModel = FeatureEditorModel()
    
    ToolPicker()
        .environment(featureEditorModel)
        .task {
            featureEditorModel.geometryEditorModel.start(withType: Polygon.self)
            await featureEditorModel.geometryEditorModel.monitorStreams()
        }
}

// MARK: - Extensions

private extension FeatureEditorGeometryTool {
    /// A localized, user-friendly label for the tool.
    var label: LocalizedStringResource {
        switch self {
        case .freehand:
            LocalizedStringResource(
                "Freehand",
                bundle: .toolkit,
                comment: "A label for a geometry editor tool that allows the user to edit using freehand gestures."
            )
        case .shape(let shape):
            shape.label
        case .vertex:
            LocalizedStringResource(
                "Vertex",
                bundle: .toolkit,
                comment: "A label for a geometry editor tool that allows the user to edit by interacting with individual vertices."
            )
        case .vertexReticle:
            LocalizedStringResource(
                "Reticle",
                bundle: .toolkit,
                comment: "A label for a geometry editor tool that allows the user to edit using a reticle."
            )
        }
    }
    
    /// The name of a system image that represents the tool.
    var systemImage: String {
        switch self {
        case .freehand: "scribble"
        case .shape(let shape): shape.systemImage
        case .vertex: "point.3.connected.trianglepath.dotted"
        case .vertexReticle: "dot.viewfinder"
        }
    }
}

private extension ShapeTool.Kind {
    /// A localized, user-friendly label for the shape tool kind.
    var label: LocalizedStringResource {
        switch self {
        case .arrow:
            LocalizedStringResource(
                "Arrow",
                bundle: .toolkit,
                comment: "A label for a geometry editor shape tool that creates an arrow."
            )
        case .ellipse:
            LocalizedStringResource(
                "Ellipse",
                bundle: .toolkit,
                comment: "A label for a geometry editor shape tool that creates an ellipse."
            )
        case .rectangle:
            LocalizedStringResource(
                "Rectangle",
                bundle: .toolkit,
                comment: "A label for a geometry editor shape tool that creates a rectangle."
            )
        case .triangle:
            LocalizedStringResource(
                "Triangle",
                bundle: .toolkitModule,
                comment: "A label for a geometry editor shape tool that creates a triangle."
            )
        @unknown default:
            fatalError("Unknown shape tool kind: \(self)")
        }
    }
    
    /// The name of a system image that represents the shape tool kind.
    var systemImage: String {
        switch self {
        case .arrow: "arrowshape.right"
        case .ellipse: "circle"
        case .rectangle: "rectangle"
        case .triangle: "triangle"
        @unknown default:
            fatalError("Unknown shape tool kind: \(self)")
        }
    }
}
