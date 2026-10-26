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
    /// The geometry editor model used by this toolbar.
    @Bindable var model: GeometryEditorModel
    
    var body: some View {
        let title = LocalizedStringResource(
            "Tool",
            bundle: .toolkit,
            comment: "A label for a control to pick a geometry editor tool."
        )
        let availableTools = model.availableTools
        Menu(title, systemImage: model.selectedTool.systemImage) {
            Picker(title, selection: $model.selectedTool) {
                ForEach(availableTools, id: \.self) { tool in
                    Label(tool.label, systemImage: tool.systemImage)
                }
            }
        }
        .accessibilityIdentifier("Tool")
        .disabled(availableTools.count < 2)
        .animation(.default, value: model.selectedTool)
    }
}

#Preview {
    @Previewable @State var model = GeometryEditorModel()
    
    ToolPicker(model: model)
        .task {
            model.start(withType: Polygon.self)
            await model.monitorStreams()
        }
}

// MARK: - Extensions

private extension FeatureEditorGeometryTool {
    /// A localized, user-friendly label for the tool.
    var label: LocalizedStringResource {
        switch self {
        case .circle:
            LocalizedStringResource(
                "Circle",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a circle."
            )
        case .freehand:
            LocalizedStringResource(
                "Freehand",
                bundle: .toolkit,
                comment: "A label for a geometry editor tool that allows the user to edit using freehand gestures."
            )
        case .line:
            LocalizedStringResource(
                "Line",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a line."
            )
        case .multipoint:
            LocalizedStringResource(
                "Multipoint",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a multipoint."
            )
        case .point:
            LocalizedStringResource(
                "Point",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a point."
            )
        case .polygon:
            LocalizedStringResource(
                "Polygon",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a polygon."
            )
        case .shape(let shape, _):
            shape.label
        case .streaming:
            LocalizedStringResource(
                "Streaming",
                bundle: .toolkit,
                comment: "A label for a geometry construction tool that creates a free-form sketch with automatically created vertices."
            )
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
        case .circle: "circle"
        case .freehand, .streaming: "scribble"
        case .shape(let shape, _): shape.systemImage
        case .line: "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .multipoint, .point: "dot.square"
        case .polygon: "skew"
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
