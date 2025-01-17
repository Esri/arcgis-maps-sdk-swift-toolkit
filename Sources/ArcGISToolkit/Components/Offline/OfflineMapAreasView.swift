// Copyright 2024 Esri
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

import SwiftUI
import ArcGIS

/// The `OfflineMapAreasView` component displays a list of downloadable preplanned map areas from a given web map.
public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @StateObject private var mapViewModel: MapViewModel
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    /// The web map to be taken offline.
    private let onlineMap: Map
    /// The currently selected map.
    @Binding private var selectedMap: Map?
    /// A Boolean value indicating whether an on-demand map area is being added.
    @State private var isAddingOnDemandArea = false
    
    /// A Boolean value indicating whether the web map is offline disabled.
    private var mapIsOfflineDisabled: Bool {
        onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil
    }
    
    /// Creates a view with a given web map.
    /// - Parameters:
    ///   - online: The web map to be taken offline.
    ///   - selection: A binding to the currently selected map.
    public init(online: Map, selection: Binding<Map?>) {
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: online))
        onlineMap = online
        _selectedMap = selection
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                if !mapIsOfflineDisabled {
                    // This is only for demo purpose. In reality it only use 1 of 2 workflow at a time.
                    Section("Preplanned") {
                        preplannedMapAreasView
                    }
                    
                    Section("On Demand") {
                        onDemandMapAreasView
                    }
                    
                    Section {
                        Button("Add Offline Area") {
                            isAddingOnDemandArea = true
                        }
                        .sheet(isPresented: $isAddingOnDemandArea) {
                            OnDemandConfigurationView(map: onlineMap.clone())
                                .onComplete { title, minScale, maxScale, areaOfInterest in
                                    let area = OnDemandMapArea(
                                        id: UUID(),
                                        title: title,
                                        minScale: minScale.scale,
                                        maxScale: maxScale.scale,
                                        areaOfInterest: areaOfInterest
                                    )
                                    mapViewModel.addOnDemandMapArea(area)
                                }
                                .highPriorityGesture(DragGesture())
                        }
                        .disabled(mapViewModel.onDemandMapModels == nil)
                    }
                }
            }
            .task {
                await loadMapModels()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Map Areas")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if mapIsOfflineDisabled {
                    offlineDisabledView
                }
            }
        }
        .refreshable {
            await loadMapModels()
        }
    }
    
    @ViewBuilder private var preplannedMapAreasView: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            if !models.isEmpty {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
                        .onChange(of: selectedMap) { _ in
                            dismiss()
                        }
                }
            } else {
                emptyPreplannedMapAreasView
            }
        case .failure(let error):
            if let urlError = error as? URLError,
               urlError.code == .notConnectedToInternet {
                offlinePreplannedMapAreasView
            } else {
                view(for: error)
            }
        case .none:
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var onDemandMapAreasView: some View {
        if let models = mapViewModel.onDemandMapModels {
            List(models) { onDemandMapModel in
                OnDemandListItemView(model: onDemandMapModel, selectedMap: $selectedMap)
                    .onChange(of: selectedMap) { _ in
                        dismiss()
                    }
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    
    @ViewBuilder private var offlinePreplannedMapAreasView: some View {
        if let models = mapViewModel.offlinePreplannedMapModels {
            if !models.isEmpty {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
                        .onChange(of: selectedMap) { _ in
                            dismiss()
                        }
                }
            } else {
                emptyOfflinePreplannedMapAreasView
            }
        } else {
            // Models are loading map areas from disk.
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    private var emptyPreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No map areas")
                .bold()
            Text("There are no map areas defined for this web map.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyOfflinePreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No map areas")
                .bold()
            Text("There are no downloaded map areas for this web map.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private var offlineDisabledView: some View {
        let labelText = Text("Offline Disabled")
        let descriptionText = Text("Please ensure the web map is offline enabled.")
        if #available(iOS 17, *) {
            ContentUnavailableView {
                labelText
                    .bold()
            } description: {
                descriptionText
            }
        } else {
            VStack(alignment: .center) {
                labelText
                    .bold()
                    .font(.title2)
                descriptionText
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var offlineBannerView: some View {
        Text("Network Offline")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: [.bottom, .horizontal])
    }
    
    private func view(for error: Error) -> some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text(error.localizedDescription)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Loads the online and offline map models.
    private func loadMapModels() async {
        // Load preplanned map models.
        await mapViewModel.loadPreplannedMapModels()
        if case .failure = mapViewModel.preplannedMapModels {
            await mapViewModel.loadOfflinePreplannedMapModels()
        }
        // Load on-demand map models.
        await mapViewModel.loadOnDemandMapModels()
    }
}

#Preview {
    @MainActor
    struct OfflineMapAreasViewPreview: View {
        @State private var map: Map?
        
        var body: some View {
            OfflineMapAreasView(
                online: Map(
                    item: PortalItem(
                        portal: .arcGISOnline(connection: .anonymous),
                        id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
                    )
                ),
                selection: $map
            )
        }
    }
    return OfflineMapAreasViewPreview()
}
