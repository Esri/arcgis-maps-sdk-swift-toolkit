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
                        preplannedMapAreasView
                    }
                }
            }
            .task {
                await loadPreplannedMapModels()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text.done
                    }
                }
            }
            .navigationTitle(mapAreasLabel)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if mapIsOfflineDisabled {
                    offlineDisabledView
                }
            }
        }
        .refreshable {
            await loadPreplannedMapModels()
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
            Text(noMapAreasTitle)
                .bold()
            Text(noMapAreasSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyOfflinePreplannedMapAreasView: some View {
        VStack(alignment: .center) {
            Text(noMapAreasTitle)
                .bold()
            Text(noDownloadedMapAreasSubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private var offlineDisabledView: some View {
        let labelText = Text(offlineDisabledTitle)
        let descriptionText = Text(offlineDisabledSubtitle)
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
    
    /// Loads the online and offline preplanned map models.
    private func loadPreplannedMapModels() async {
        await mapViewModel.loadPreplannedMapModels()
        if case .failure = mapViewModel.preplannedMapModels {
            await mapViewModel.loadOfflinePreplannedMapModels()
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

private extension OfflineMapAreasView {
    var mapAreasLabel: String {
        .init(
            localized: "Map Areas",
            bundle: .toolkitModule,
            comment: "A label for the map areas view."
        )
    }
    
    var noMapAreasTitle: String {
        .init(
            localized: "No map areas",
            bundle: .toolkitModule,
            comment: "A label indicating that the map has no map areas."
        )
    }
    
    var noMapAreasSubtitle: String {
        .init(
            localized: "There are no map areas defined for this web map.",
            bundle: .toolkitModule,
            comment: "A label indicating that there are no map areas defined for the web map."
        )
    }
    
    var noDownloadedMapAreasSubtitle: String {
        .init(
            localized: "There are no downloaded map areas for this web map.",
            bundle: .toolkitModule,
            comment: "A label indicating that there are no downloaded map areas for the web map."
        )
    }
    
    var offlineDisabledTitle: String {
        .init(
            localized: "Offline disabled",
            bundle: .toolkitModule,
            comment: "A label indicating that the web map is offline disabled."
        )
    }
    
    var offlineDisabledSubtitle: String {
        .init(
            localized: "Please ensure the web map is offline enabled.",
            bundle: .toolkitModule,
            comment: "A label indicating that the user should check that the web map is offline enabled."
        )
    }
}
