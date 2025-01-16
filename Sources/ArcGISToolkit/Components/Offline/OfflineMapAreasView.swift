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
@MainActor
@preconcurrency
public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @StateObject private var mapViewModel: MapViewModel
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    /// The web map to be taken offline.
    private let onlineMap: Map
    /// The currently selected map.
    @Binding private var selectedMap: Map?
    
    /// The portal item for the web map to be taken offline.
    private var portalItem: PortalItem? {
        onlineMap.item as? PortalItem
    }
    
    /// Creates a view with a given web map.
    /// - Parameters:
    ///   - online: The web map to be taken offline.
    ///   - selection: A binding to the currently selected map.
    /// - Precondition: `onlineMap.item?.id` is not `nil`.
    public init(onlineMap: Map, selection: Binding<Map?>) {
        precondition(onlineMap.item?.id != nil)
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: onlineMap))
        self.onlineMap = onlineMap
        _selectedMap = selection
    }
    
    public init(mapInfo: OfflineMapInfo, selection: Binding<Map?>) {
        let item = PortalItem(url: mapInfo.portalItemURL)!
        let map = Map(item: item)
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: map))
        onlineMap = map
        _selectedMap = selection
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    if !mapViewModel.mapIsOfflineDisabled {
                        preplannedMapAreasView
                    }
                }
            }
            .task {
                await mapViewModel.loadPreplannedMapModels()
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
            await mapViewModel.loadPreplannedMapModels()
        }
    }
    
    @ViewBuilder private var preplannedMapAreasView: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            if !models.isEmpty {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap)
                        .onDownload {
                            guard let portalItem else { return }
                            OfflineManager.shared.saveMapInfo(for: portalItem)
                        }
                        .onRemoveDownload {
                            guard let portalItemID = portalItem?.id,
                                  models.filter(\.status.isDownloaded).isEmpty else { return }
                            OfflineManager.shared.deleteMapInfo(for: portalItemID)
                        }
                        .onChange(of: selectedMap) { _ in
                            dismiss()
                        }
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
                        id: PortalItem.ID("acc027394bc84c2fb04d1ed317aac674")!
                    )
                ),
                selection: $map
            )
        }
    }
    return OfflineMapAreasViewPreview()
}
