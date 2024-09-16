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
    
    /// The currently selected map.
    @Binding private var selectedMap: Map?
    
    /// Creates a view with a given web map.
    /// - Parameters:
    ///   - online: The web map to be taken offline.
    ///   - selection: A binding to the currently selected map.
    public init(online: Map, selection: Binding<Map?>) {
        _mapViewModel = StateObject(wrappedValue: MapViewModel(map: online))
        _selectedMap = selection
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    if networkMonitor.isConnected {
                        preplannedMapAreasView
                    } else {
                        offlinePreplannedMapAreasView
                    }
                } header: {
                    Text("Preplanned")
                        .bold()
                }
                .textCase(nil)
            }
            .task {
                await makePreplannedMapModels()
            }
            .task {
                await mapViewModel.requestUserNotificationAuthorization()
            }
            .onChange(of: networkMonitor.isConnected) { _ in
                Task {
                    await makePreplannedMapModels()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Offline Maps")
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
        if let models = mapViewModel.offlinePreplannedMapModels,
           !models.isEmpty {
            List(models) { preplannedMapModel in
                PreplannedListItemView(model: preplannedMapModel, selectedMap: $selectedMap) {
                    Task { await makePreplannedMapModels() }
                }
                .onChange(of: selectedMap) { _ in
                    dismiss()
                }
            }
        } else {
            emptyOfflinePreplannedMapAreasView
        }
    }
    
    @ViewBuilder private var emptyPreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No offline map areas")
                .bold()
            Text("You don't have any offline map areas yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private var emptyOfflinePreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text("No offline map areas")
                .bold()
            Text("You don't have any downloaded offline map areas yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func errorView(_ error: Error) -> some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle")
                .imageScale(.large)
                .foregroundStyle(.red)
            Text(error.localizedDescription)
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Makes the appropriate preplanned map models depending on the device network connection.
    private func makePreplannedMapModels() async {
        if networkMonitor.isConnected {
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
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
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
