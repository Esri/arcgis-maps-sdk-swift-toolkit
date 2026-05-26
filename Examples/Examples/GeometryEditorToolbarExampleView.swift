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
import ArcGISToolkit
import SwiftUI

struct GeometryEditorToolbarExampleView: View {
    /// The geometry editor used to edit geometries on the map view.
    @State private var geometryEditor = GeometryEditor()
    /// The graphics overlay for displaying the created graphics on the map view.
    @State private var graphicsOverlay = GraphicsOverlay()
    /// The map displayed in the map view.
    @State private var map = Map(basemapStyle: .arcGISTopographic)
    /// A Boolean value indicating whether the view is currently editing a geometry.
    @State private var isEditing = false
    
    var body: some View {
        MapView(map: map, graphicsOverlays: [graphicsOverlay])
            .geometryEditor(geometryEditor)
            .overlay(alignment: .topTrailing) {
                GeometryEditorToolbar(geometryEditor: geometryEditor)
                    .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Menu("Add Graphic", systemImage: "plus") {
                        ForEach(GeometryKind.allCases, id: \.self) { geometryKind in
                            Button(geometryKind.label) {
                                geometryEditor.start(withType: geometryKind.type)
                                isEditing = true
                            }
                        }
                    }
                    .disabled(isEditing)
                    
                    Button("Done", systemImage: "checkmark") {
                        addGraphic()
                        isEditing = false
                    }
                    .disabled(!isEditing)
                }
            }
    }
    
    /// Creates a graphic from the geometry editor's geometry and adds it to the graphics overlay.
    private func addGraphic() {
        guard let geometry = geometryEditor.stop(), !geometry.isEmpty else { return }
        
        let symbol = switch geometry {
        case is Point:
            SimpleMarkerSymbol(color: .blue)
        case is Polyline:
            SimpleLineSymbol(color: .black, width: 2)
        case is ArcGIS.Polygon:
            SimpleFillSymbol(color: .green)
        default:
            fatalError("Unsupported geometry type")
        }
        let graphic = Graphic(geometry: geometry, symbol: symbol)
        graphicsOverlay.addGraphic(graphic)
    }
}

/// An enumeration representing the kinds of geometries that can be created in this example.
private enum GeometryKind: CaseIterable {
    case point, polyline, polygon
    
    /// A user-friendly label for the geometry kind.
    var label: String {
        switch self {
        case .point: "Point"
        case .polyline: "Polyline"
        case .polygon: "Polygon"
        }
    }
    
    /// The `Geometry.Type` corresponding to the geometry kind.
    var type: Geometry.Type {
        switch self {
        case .point: Point.self
        case .polyline: Polyline.self
        case .polygon: ArcGIS.Polygon.self
        }
    }
}
