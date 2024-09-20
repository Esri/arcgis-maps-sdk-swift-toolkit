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
import Network

/// The `OfflineMapAreasView` component displays a list of downloadable preplanned map areas from a given web map.
@MainActor
@preconcurrency
public struct OfflineMapAreasView: View {
    /// The view model for the map.
    @StateObject private var mapViewModel: MapViewModel
    
    /// The network monitor.
    @StateObject private var networkMonitor = NetworkMonitor()
    
    /// The action to dismiss the view.
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    /// The web map to be taken offline.
    private let onlineMap: Map
    
    /// The currently selected map.
    @Binding private var selectedMap: Map?
    
    /// A Boolean value indicating whether the device has an internet connection.
    @State private var isConnected = true
    
    /// A Boolean value indicating whether the offline banner should be presented.
    @State private var offlineBannerIsPresented = false
    
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
                    if onlineMap.loadStatus == .loaded && onlineMap.offlineSettings == nil {
                        offlineDisabledView
                    } else if isConnected {
                        preplannedMapAreasView
                    } else {
                        offlinePreplannedMapAreasView
                    }
                }
            }
            .task {
                await mapViewModel.requestUserNotificationAuthorization()
            }
            .task {
                await makePreplannedMapModels()
            }
            .onChange(of: networkMonitor.isConnected) { _ in
                offlineBannerIsPresented = !networkMonitor.isConnected
            }
            .overlay(alignment: .bottom) {
                if offlineBannerIsPresented {
                    offlineBannerView
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Map Areas")
            .navigationBarTitleDisplayMode(.inline)
        }
        .refreshable {
            await makePreplannedMapModels()
        }
    }
    
    @ViewBuilder private var preplannedMapAreasView: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            if !models.isEmpty {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap) {}
                        .onChange(of: selectedMap) { _ in
                            dismiss()
                        }
                }
            } else {
                emptyPreplannedMapAreasView
            }
        case .failure(let error):
            errorView(error)
        case .none:
            ProgressView()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder private var offlinePreplannedMapAreasView: some View {
        if let models = mapViewModel.offlinePreplannedMapModels {
            if !models.isEmpty {
                List(models) { preplannedMapModel in
                    PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap, onDeletion: {
                        Task { await makePreplannedMapModels() }
                    })
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
            Text("The web map doesn't contain specified offline map areas.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyOfflinePreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No map areas")
                .bold()
            Text("You don't have any downloaded map areas yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var offlineDisabledView: some View {
        VStack(alignment: .center) {
            Text("Offline disabled")
                .bold()
            Text("Please ensure the web map is offline enabled.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var offlineBannerView: some View {
        Text("Network Offline")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(.ultraThinMaterial, ignoresSafeAreaEdges: [.bottom, .horizontal])
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text(error.localizedDescription)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Makes the appropriate preplanned map models depending on the updated device network connection.
    private func makePreplannedMapModels() async {
        isConnected = networkMonitor.isConnected
        
        if isConnected {
            await mapViewModel.makePreplannedMapModels()
        } else {
            await mapViewModel.makeOfflinePreplannedMapModels()
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

@MainActor
private class NetworkMonitor: ObservableObject {
    /// The path mointor to observe network changes.
    private let monitor = NWPathMonitor()
    
    /// A Boolean value indicating whether the device has an internet connection.
    @Published private(set) var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
