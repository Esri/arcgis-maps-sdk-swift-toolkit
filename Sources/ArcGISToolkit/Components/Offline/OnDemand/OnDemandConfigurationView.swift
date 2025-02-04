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

/// A view that can provides a configuration for taking an on-demand area offline.
struct OnDemandConfigurationView: View {
    /// The online map.
    @State private(set) var map: Map
    
    /// The title of the map area.
    @State private(set) var title: String
    
    /// A check to perform to validate a proposed title for uniqueness.
    let titleIsValidCheck: (String) -> Bool
    
    /// The action to call when creating a configuration is complete.
    let onCompleteAction: (OnDemandMapAreaConfiguration) -> Void
    
    /// The max scale of the map to take offline.
    @State private var maxScale: CacheScale = .street
    
    /// The visible area of the map.
    @State private var visibleArea: Envelope?
    
    // The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    /// A Boolean value indicating if the download button is disabled.
    private var downloadIsDisabled: Bool {
        visibleArea == nil
    }
    
    /// The scale or the map area selector.
    private let mapAreaScale = 0.8
    
    /// The scaled downn visible area for the map area selector.
    private var scaledVisibleArea: Envelope? {
        if let visibleArea {
            GeometryEngine.scale(visibleArea, factorX: mapAreaScale, factorY: mapAreaScale)?.extent
        } else {
            nil
        }
    }
    
    var body: some View {
        NavigationStack {
            MapViewReader { mapViewProxy in
                VStack {
                    VStack(spacing: 0) {
                        Divider()
                        Text("Pan and zoom to define the area")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                        Divider()
                        ZStack {
                            mapView
                            if let scaledVisibleArea {
                                OnDemandMapAreaSelectorView(mapViewProxy: mapViewProxy, envelope: scaledVisibleArea)
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    bottomPane(mapView: mapViewProxy)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
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
            .onVisibleAreaChanged { visibleArea = $0.extent }
            // Prevent view from dragging when panning on map view.
            .highPriorityGesture(DragGesture())
            .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    private func bottomPane(mapView: MapViewProxy) -> some View {
        BottomCard(background: Color(uiColor: .systemBackground)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                    NewTitleButton(title: title, isValidCheck: titleIsValidCheck) {
                        title = $0
                    }
                }
                
                HStack {
                    Picker("Level of detail", selection: $maxScale) {
                        ForEach(CacheScale.allCases, id: \.self) {
                            Text($0.description)
                        }
                    }
                    .font(.footnote)
                    .pickerStyle(.navigationLink)
                }
                .padding(.vertical, 6)
                
                HStack {
                    Button {
                        guard let visibleArea else { return }
                        Task {
                            let thumbnail = try? await mapView.exportImage()
                            let configuration = OnDemandMapAreaConfiguration(
                                title: title,
                                minScale: 0,
                                maxScale: maxScale.scale,
                                areaOfInterest: visibleArea,
                                thumbnail: thumbnail
                            )
                            onCompleteAction(configuration)
                            dismiss()
                        }
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

/// A View that allows renaming of a map area.
private struct NewTitleButton: View {
    /// The current title.
    let title: String
    
    /// An validity check for a proposed title.
    let isValidCheck: (String) -> Bool
    
    /// The completion of the rename.
    let completion: (String) -> Void
    
    /// A Boolean value indicating if we are showing the alert to
    /// rename the title.
    @State private var alertIsShowing = false
    
    /// Temporary storage for a proposed title for use when the user is renaming an area.
    @State private var proposedNewTitle: String = ""
    
    /// A Boolean value indicating if the proposed title is valid.
    @State private var proposedTitleIsValid = false
    
    var body: some View {
        Button {
            // Rename the area.
            proposedNewTitle = title
            alertIsShowing = true
        } label: {
            Image(systemName: "pencil")
        }
        .alert("Enter a name", isPresented: $alertIsShowing) {
            TextField("Enter area name", text: $proposedNewTitle)
            Button("OK", action: submitNewTitle)
                .disabled(!proposedTitleIsValid)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The name for the map area must be unique.")
        }
        .onChange(of: proposedNewTitle) {
            proposedTitleIsValid = isValidCheck($0)
        }
    }
    
    /// Completes the rename.
    private func submitNewTitle() {
        completion(proposedNewTitle)
    }
}

/// A view that displays a card with rounded top edges that will be
/// anchored to the bottom.
private struct BottomCard<Content: View, Background: ShapeStyle>: View {
    /// The content to display in the card.
    let content: () -> Content
    /// The background of the card.
    let background: Background
    
    /// Creates a bottom card.
    init(background: Background, @ViewBuilder content: @escaping () -> Content) {
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
