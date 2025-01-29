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
    let title: String = "hello"
    let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
    
    @State private var maxScale: CacheScale = .room
    @State private var currentVisibleArea: Polygon?
    
    @Environment(\.dismiss) private var dismiss
    
    var downloadIsDisabled: Bool {
        currentVisibleArea == nil
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 0) {
                    Divider()
                    Text("Pan and zoom to define the area")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                    Divider()
                    mapView
                }
            }
            .safeAreaInset(edge: .bottom) {
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
        }
    }
    
    @ViewBuilder
    private var mapView: some View {
        MapView(map: map)
            .magnifierDisabled(true)
            .attributionBarHidden(true)
            .interactionModes([.pan, .zoom])
            .onVisibleAreaChanged { currentVisibleArea = $0 }
    }
    
    @ViewBuilder
    private var bottomPane: some View {
        BottomCard(background: Color(uiColor: .systemBackground)) {
            VStack {
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
                            title: title,
                            minScale: CacheScale.worldSmall.scale,
                            maxScale: maxScale.scale,
                            areaOfInterest: currentVisibleArea.extent
                        )
                        onCompleteAction(configuration)
                        dismiss()
                    } label: {
                        Label("Download", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .disabled(downloadIsDisabled)
                }
            }
            .padding()
        }
    }
}

private struct BottomCard<Content: View, Background: ShapeStyle>: View {
    let content: () -> Content
    let background: Background
    
    init(background: Background,@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.background = background
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
                .background(background)
                .clipShape(
                    .rect(
                        topLeadingRadius: 12,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 12
                    )
                )
            
            // So it extends into the bottom safe area.
            VStack {}
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .background(background)
        }
        .ignoresSafeArea(.container, edges: .horizontal)
    }
}
