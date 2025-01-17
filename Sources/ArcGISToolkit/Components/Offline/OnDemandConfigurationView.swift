// Copyright 2025 Esri
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

struct OnDemandConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    let map: Map
    @State private var titleInput = ""
    @State private var maxScale: CacheScale = .room
    @State private var polygon: Polygon?
    @State private var currentVisibleArea: Polygon?
    @State private var geometryEditor = GeometryEditor()
    
    var onCompleteAction: ((String, CacheScale, CacheScale, Polygon) -> Void)? = nil
    
    var cannotAddOnDemandArea: Bool {
        titleInput.isEmpty || polygon == nil
    }
    
    func onComplete(
        perform action: @escaping (String, CacheScale, CacheScale, Polygon) -> Void
    ) -> Self {
        var view = self
        view.onCompleteAction = action
        return view
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Drag the selector to define the area")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, ignoresSafeAreaEdges: .horizontal)
                
                mapSelectorView
                
                bottomPane
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationBarTitle("Select Area")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    @ViewBuilder
    private var bottomPane: some View {
        VStack {
            HStack {
                Text("Title")
                TextField("Type here", text: $titleInput)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Picker("Max Scale", selection: $maxScale) {
                    ForEach(CacheScale.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
                .pickerStyle(.navigationLink)
            }
            
            HStack {
                Button {
                    if polygon == nil {
                        polygon = currentVisibleArea
                        startEditing(polygon: polygon!)
                    } else {
                        geometryEditor.stop()
                        polygon = nil
                    }
                } label: {
                    Text(polygon == nil ? "Show Selector": "Hide Selector")
                        .bold()
                        .font(.body)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.secondary.opacity(0.4))
                .cornerRadius(10)
                .disabled(currentVisibleArea == nil)
                
                Button {
                    Task {
                        geometryEditor.stop()
                        onCompleteAction?(titleInput, .worldSmall, maxScale, polygon!)
                        dismiss()
                    }
                } label: {
                    Text("Download")
                        .bold()
                        .font(.body)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
                .disabled(cannotAddOnDemandArea)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thickMaterial)
        .clipShape(
            .rect(
                topLeadingRadius: 10,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 10
            )
        )
    }
    
    @ViewBuilder
    private var mapSelectorView: some View {
        MapView(map: map)
            .interactionModes([.pan, .zoom])
            .geometryEditor(geometryEditor)
            .onVisibleAreaChanged { area in
                currentVisibleArea = area
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    print("Location Button tapped")
                } label: {
                    Image(systemName: "location.slash")
                        .padding(8)
                }
                .padding(8)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding()
            }
            .task {
                for await polygon in geometryEditor.$geometry {
                    // Update geometry when there is an update.
                    self.polygon = polygon as? Polygon
                }
            }
    }
    
    func startEditing(polygon: Polygon) {
        let tool = ShapeTool(kind: .rectangle)
        tool.configuration.scaleMode = .stretch
        tool.configuration.allowsRotatingSelectedElement = false
        tool.style.fillSymbol = SimpleFillSymbol(style: .solid, color: .lightGray.withAlphaComponent(0.3))
        geometryEditor.tool = tool
        
        geometryEditor.start(withInitial: polygon)
        geometryEditor.selectGeometry()
        geometryEditor.scaleSelectedElementBy(factorX: 0.8, factorY: 0.8)
    }
}
