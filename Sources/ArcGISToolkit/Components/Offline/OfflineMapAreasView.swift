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
                Section {
                    if !mapIsOfflineDisabled {
                        preplannedMapAreaViews
                    }
                }
            }
            .task {
                await mapViewModel.makePreplannedOfflineMapModels()
            }
            .task {
                await mapViewModel.requestUserNotificationAuthorization()
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
            await mapViewModel.makePreplannedOfflineMapModels()
        }
    }
    
    @ViewBuilder private var preplannedMapAreaViews: some View {
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
            VStack(alignment: .center) {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                Text(error.localizedDescription)
            }
            .frame(maxWidth: .infinity)
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
    
    private var offlineDisabledView: some View {
        if #available(iOS 17, *) {
            return ContentUnavailableView {
                Text("Offline Disabled")
                    .bold()
            } description: {
                Text("Please ensure the web map is offline enabled.")
            }
        } else {
            return VStack(alignment: .center) {
                Text("Offline Disabled")
                    .bold()
                    .font(.title2)
                Text("Please ensure the web map is offline enabled.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
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
