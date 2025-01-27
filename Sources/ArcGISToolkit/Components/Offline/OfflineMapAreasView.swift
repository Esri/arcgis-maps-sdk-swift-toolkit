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
    @StateObject private var mapViewModel: OfflineMapViewModel
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    /// The web map to be taken offline.
    private let onlineMap: Map
    /// The currently selected map.
    @Binding private var selectedMap: Map?
    /// A Boolean value indicating whether an on-demand map area is being added.
    @State private var isAddingOnDemandArea = false
    
    /// The portal item for the web map to be taken offline.
    private var portalItem: PortalItem {
        // Safe to force cast because of the precondition in the initializer.
        onlineMap.item as! PortalItem
    }
    
    /// The `ID` of the portal item.
    private var portalItemID: Item.ID {
        // Safe to force unwrap because of the precondition in the initializer.
        portalItem.id!
    }
    
    /// Creates a view with a given web map.
    /// - Parameters:
    ///   - onlineMap: The web map to be taken offline.
    ///   - selection: A binding to the currently selected offline map.
    /// - Precondition: `onlineMap.item?.id` is not `nil`.
    /// - Precondition: `onlineMap.item` is of type `PortalItem`.
    public init(onlineMap: Map, selection: Binding<Map?>) {
        precondition(onlineMap.item?.id != nil)
        precondition(onlineMap.item is PortalItem)
        _mapViewModel = StateObject(wrappedValue: OfflineManager.shared.model(for: onlineMap))
        self.onlineMap = onlineMap
        _selectedMap = selection
    }
    
    /// Creates a view with a given offline map info.
    /// - Parameters:
    ///   - offlineMapInfo: The offline map info for which to create the view.
    ///   - selection: A binding to the currently selected offline map.
    public init(offlineMapInfo: OfflineMapInfo, selection: Binding<Map?>) {
        let item = PortalItem(url: offlineMapInfo.portalItemURL)!
        let onlineMap = Map(item: item)
        _mapViewModel = StateObject(wrappedValue: OfflineManager.shared.model(for: onlineMap))
        self.onlineMap = onlineMap
        _selectedMap = selection
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Preplanned") {
                    if !mapViewModel.mapIsOfflineDisabled {
                        preplannedMapAreasView
                    }
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
                if mapViewModel.mapIsOfflineDisabled {
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
                }
            } else {
                emptyPreplannedMapAreasView
            }
        case .failure(let error):
            view(for: error)
        case .none:
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var onDemandMapAreasView: some View {
        if let models = mapViewModel.onDemandMapModels {
            List(models) { onDemandMapModel in
                OnDemandListItemView(model: onDemandMapModel, selectedMap: $selectedMap)
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var emptyPreplannedMapAreasView: some View {
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
                onlineMap: Map(
                    item: PortalItem(
                        portal: .arcGISOnline(connection: .anonymous),
                        id: Item.ID("acc027394bc84c2fb04d1ed317aac674")!
                    )
                ),
                selection: $map
            )
        }
    }
    return OfflineMapAreasViewPreview()
}
