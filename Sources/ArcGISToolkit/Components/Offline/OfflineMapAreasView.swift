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
            VStack {
                if mapViewModel.isLoadingModels {
                    ProgressView()
                } else {
                    if mapViewModel.mapIsOfflineDisabled {
                        offlineDisabledView
                    } else {
                        switch mapViewModel.mode {
                        case .preplanned:
                            preplannedMapAreasView
                        case .onDemand, .undetermined:
                            onDemandMapAreasView
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
            .task {
                await mapViewModel.loadModels()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Map Areas")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder private var preplannedMapAreasView: some View {
        List {
            switch mapViewModel.preplannedMapModels {
            case .success(let models):
                if !models.isEmpty {
                    Section {
                        ForEach(models) { preplannedMapModel in
                            PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
                        }
                    } footer: {
                        if mapViewModel.isShowingOnlyOfflineModels {
                            // If we are showing some models, but only offline models,
                            // show that information in a footer.
                            noInternetFooter
                        }
                    }
                } else if mapViewModel.isShowingOnlyOfflineModels {
                    // If we have no models and no internet, show a content unavailable view.
                    noInternetNoAreasView
                } else {
                    // If the request was successful, but there are no preplanned
                    // map areas, then show empty preplanned map areas view.
                    // This shouldn't happen unless preplanned areas were deleted after establishing
                    // preplanned mode on the model. Because there needs to be preplanned areas
                    // to even establish the preplanned mode.
                    emptyPreplannedOfflineAreasView
                }
            case .failure:
                preplannedErrorView
            }
        }
        .refreshable {
            Task { await mapViewModel.loadModels() }
        }
    }
    
    @ViewBuilder private var onDemandMapAreasView: some View {
        List {
            if !mapViewModel.onDemandMapModels.isEmpty {
                ForEach(mapViewModel.onDemandMapModels) { onDemandMapModel in
                    OnDemandListItemView(model: onDemandMapModel, selectedMap: $selectedMap)
                }
            } else {
                emptyOnDemandOfflineAreasView
            }
            Section {
                Button("Add Offline Area") {
                    isAddingOnDemandArea = true
                }
                .sheet(isPresented: $isAddingOnDemandArea) {
                    OnDemandConfigurationView(
                        map: onlineMap.clone(),
                        title: mapViewModel.nextOnDemandAreaTitle(),
                        titleIsValidCheck: mapViewModel.isProposeOnDemandAreaTitleUnique(_:)
                    ) {
                        mapViewModel.addOnDemandMapArea(with: $0)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var noInternetFooter: some View {
        Label("No internet connection. Showing downloaded areas only.", systemImage: "wifi.exclamationmark")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder private var noInternetNoAreasView: some View {
        Backported.ContentUnavailableView(
            "No Internet Connection",
            systemImage: "wifi.exclamationmark",
            description: "Could not retrieve map areas for this map. Pull to refresh."
        )
    }
    
    @ViewBuilder private var emptyPreplannedOfflineAreasView: some View {
        Backported.ContentUnavailableView(
            "No Map Areas",
            systemImage: "arrow.down.circle",
            description: "There are no offline map areas for this map. Pull to refresh."
        )
    }
    
    @ViewBuilder private var emptyOnDemandOfflineAreasView: some View {
        Backported.ContentUnavailableView(
            "No Map Areas",
            systemImage: "arrow.down.circle",
            description: "There are no offline map areas for this map. Tap the button below to get started."
        )
    }
    
    @ViewBuilder private var offlineDisabledView: some View {
        Backported.ContentUnavailableView(
            "Offline Disabled",
            systemImage: "exclamationmark.triangle",
            description: "Please ensure the map is offline enabled."
        )
    }
    
    @ViewBuilder private var preplannedErrorView: some View {
        Backported.ContentUnavailableView(
            "Error Fetching Map Areas",
            systemImage: "exclamationmark.triangle",
            description: "An error occurred while fetching map areas. Pull to refresh."
        )
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

enum Backported {
    /// A content unavailable view that can be used in older operating systems.
    struct ContentUnavailableView: View {
        let title: LocalizedStringKey
        let systemImage: String
        let description: String?
        
        init(_ title: LocalizedStringKey, systemImage name: String, description: String? = nil) {
            self.title = title
            self.systemImage = name
            self.description = description
        }
        
        var body: some View {
            if #available(iOS 17, *) {
                SwiftUI.ContentUnavailableView(
                    title,
                    systemImage: systemImage,
                    description: description.map { Text($0) }
                )
            } else {
                VStack(alignment: .center) {
                    Image(systemName: systemImage)
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.headline)
                    if let description {
                        Text(description)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
