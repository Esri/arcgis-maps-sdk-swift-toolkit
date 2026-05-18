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
    @State private var map = Map(
        url: URL(string: "https://www.arcgis.com/home/item.html?id=b95fe18073bc4f7788f0375af2bb445e")!
    )!
    @State private var geometryEditor = GeometryEditor()
    @State private var identifyPoint: CGPoint?
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .geometryEditor(geometryEditor)
                .onSingleTapGesture { screenPoint, _ in
                    identifyPoint = screenPoint
                }
                .task(id: identifyPoint) {
                    guard let identifyPoint else { return }
                    defer { self.identifyPoint = nil }
                    
                    do {
                        let identifyLayerResults = try await mapViewProxy.identifyLayers(
                            screenPoint: identifyPoint,
                            tolerance: 10
                        )
                        
                        guard let result = identifyLayerResults.first,
                              let feature = result.geoElements.first as? ArcGISFeature,
                              let geometry = feature.geometry else {
                            return
                        }
                        geometryEditor.start(withInitial: geometry)
                    } catch {
                        print("Error: \(error)")
                    }
                }
                .overlay(alignment: .topTrailing) {
                    GeometryEditorToolbar(geometryEditor: geometryEditor)
                        .padding()
                }
                .overlay(alignment: .bottomTrailing) {
                    GeometryEditorToolbar(geometryEditor: geometryEditor, layout: .horizontal)
                        .padding()
                        .padding(.bottom, 25)
                }
                .overlay(alignment: .bottomLeading) {
                    AddFeatureButton(geometryEditor: geometryEditor)
                        .padding()
                        .padding(.bottom, 25)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        GeometryEditorToolbar(geometryEditor: geometryEditor, layout: nil)
                    }
                }
        }
    }
}

private struct AddFeatureButton: View {
    let geometryEditor: GeometryEditor
    
    var body: some View {
        Menu("Add Feature", systemImage: "plus") {
            ForEach(GeometryOption.allCases, id: \.self) { geometryOption in
                Button(geometryOption.label) {
                    geometryEditor.start(withType: geometryOption.type)
                }
            }
        }
        .labelStyle(.iconOnly)
        .padding()
        .background(.regularMaterial)
        .clipShape(.capsule)
    }
    
    private enum GeometryOption: CaseIterable {
        case multipoint
        case point
        case polygon
        case polyline
        
        var label: String {
            switch self {
            case .multipoint: "Multipoint"
            case .point: "Point"
            case .polygon: "Polygon"
            case .polyline: "Polyline"
            }
        }
        
        var type: Geometry.Type {
            switch self {
            case .multipoint: Multipoint.self
            case .point: Point.self
            case .polygon: Polygon.self
            case .polyline: Polyline.self
            }
        }
    }
}
