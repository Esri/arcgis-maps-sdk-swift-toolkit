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

// TODO: doc
struct OnDemandConfigurationView: View {
    let map: Map
    let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
    
    @State private var titleInput = ""
    @State private var maxScale: CacheScale = .room
    @State private var polygon: Polygon?
    @State private var currentVisibleArea: Polygon?
    
    @Environment(\.dismiss) private var dismiss
    
    var cannotAddOnDemandArea: Bool {
        titleInput.isEmpty || currentVisibleArea == nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // TODO: this should extend the top safe area
                Text("Pan and zoom to define the area")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, ignoresSafeAreaEdges: .horizontal)
                
                mapView
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
                    guard let currentVisibleArea else { return }
                    let configuration = OnDemandMapAreaConfiguration(
                        title: titleInput,
                        minScale: CacheScale.worldSmall.scale,
                        maxScale: maxScale.scale,
                        areaOfInterest: currentVisibleArea
                    )
                    onCompleteAction(configuration)
                    dismiss()
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
    private var mapView: some View {
        MapView(map: map)
            .interactionModes([.pan, .zoom])
            .onVisibleAreaChanged { currentVisibleArea = $0 }
    }
}
