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

/// The tools supported by the feature editor.
enum FeatureEditorGeometryTool: Hashable {
    case circle
    case freehand
    case line
    case multipoint
    case point
    case polygon
    case shape(kind: ShapeTool.Kind, allowsPartCreation: Bool = true)
    case streaming
    case vertex
    case vertexReticle
    
    /// The geometry editor tool associated with the tool.
    var geometryEditorTool: GeometryEditorTool {
        let tool: GeometryEditorTool
        switch self {
        case .circle:
            let shapeTool = ShapeTool(kind: .ellipse)
            shapeTool.configuration.scaleMode = .uniform
            tool = shapeTool
        case .freehand:
            tool = FreehandTool()
        case .shape(let kind, let allowsPartCreation):
            let shapeTool = ShapeTool(kind: kind)
            shapeTool.configuration.allowsPartCreation = allowsPartCreation
            tool = shapeTool
        case .streaming:
            tool = FreehandTool()
            // Uses the `VertexTool`'s style so that vertex symbols are shown.
            tool.style = VertexTool().style
        case .line, .multipoint, .point, .polygon, .vertex:
            tool = VertexTool()
        case .vertexReticle:
            tool = ReticleVertexTool()
        }
        
        // Makes the fill symbol semi-transparent to avoid obscuring the map
        // beneath polygons.
        if let fillSymbol = tool.style.fillSymbol as? FillSymbol {
            fillSymbol.color = fillSymbol.color.withAlphaComponent(0.5)
        }
        
        return tool
    }
    
    /// The geometry types that the tool can be used with.
    var supportedGeometryTypes: [Geometry.Type] {
        switch self {
        case .circle, .freehand, .shape, .streaming:
            [Polygon.self, Polyline.self]
        case .line:
            [Polyline.self]
        case .multipoint:
            [Multipoint.self]
        case .point:
            [Point.self]
        case .polygon:
            [Polygon.self]
        case .vertex, .vertexReticle:
            [Multipoint.self, Point.self, Polygon.self, Polyline.self]
        }
    }
}

extension FeatureEditorGeometryTool {
    /// The tools for editing an existing geometry.
    static var editingTools: [Self] {
        [
            .vertex,
            .vertexReticle,
            .shape(kind: .arrow),
            .shape(kind: .ellipse),
            .shape(kind: .rectangle),
            .shape(kind: .triangle),
            .freehand
        ]
    }
}
