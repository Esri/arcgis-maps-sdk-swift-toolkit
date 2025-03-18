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
    /// The visibility of the done button.
    private var doneVisibility: Visibility = .automatic
    /// A Boolean value indicating whether the view should dismiss.
    private var shouldDismiss: Bool {
        doneVisibility == .automatic || doneVisibility == .visible
    }
    
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
    
    /// Specifies the visibility of the done button.
    /// - Parameter visibility: The preferred visibility of the done button.
    public func doneButton(_ visibility: Visibility) -> Self {
        var copy = self
        copy.doneVisibility = visibility
        return copy
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
            #if !os(visionOS)
            // This frame is required to set the background to cover the whole view.
            // Otherwise when the progress view is showing, the background will
            // only cover the progress view.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(uiColor: .systemGroupedBackground))
            #endif
            .interactiveDismissDisabled()
            .task {
                await mapViewModel.loadModels()
            }
            // Note: the sheet has to be here rather than off of the `onDemandMapAreasView`
            // or else the state is lost when backgrounding and foregrounding the application.
            .sheet(isPresented: $isAddingOnDemandArea) {
                OnDemandConfigurationView(
                    map: onlineMap.clone(),
                    title: mapViewModel.nextOnDemandAreaTitle(),
                    titleIsValidCheck: mapViewModel.isProposeOnDemandAreaTitleUnique(_:)
                ) {
                    mapViewModel.addOnDemandMapArea(with: $0)
                }
            }
            .toolbar {
                if shouldDismiss {
                    ToolbarItem(placement: .confirmationAction) {
                        Button.done {
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(
                Text(
                    "Map Areas",
                    bundle: .toolkitModule,
                    comment: "A title for the offline map areas view."
                )
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder private var preplannedMapAreasView: some View {
        switch mapViewModel.preplannedMapModels {
        case .success(let models):
            if !models.isEmpty {
                List {
                    Section {
                        ForEach(models) { preplannedMapModel in
                            PreplannedListItemView(
                                model: preplannedMapModel,
                                selectedMap: $selectedMap,
                                shouldDismiss: shouldDismiss
                            )
                        }
                    } footer: {
                        if mapViewModel.isShowingOnlyOfflineModels {
                            // If we are showing some models, but only offline models,
                            // show that information in a footer.
                            noInternetFooter
                        }
                    }
                }
                .refreshable {
                    Task { await mapViewModel.loadModels() }
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
    
    @ViewBuilder private var onDemandMapAreasView: some View {
        VStack {
            if !mapViewModel.onDemandMapModels.isEmpty {
                List {
                    ForEach(mapViewModel.onDemandMapModels) { onDemandMapModel in
                        OnDemandListItemView(
                            model: onDemandMapModel,
                            selectedMap: $selectedMap,
                            shouldDismiss: shouldDismiss
                        )
                    }
                    Section {
                        Button {
                            isAddingOnDemandArea = true
                        } label: {
                            addMapArea
                        }
                    }
                }
            } else {
                emptyOnDemandOfflineAreasView
            }
        }
    }
    
    @ViewBuilder private var refreshPreplannedButton: some View {
        Button {
            Task { await mapViewModel.loadModels() }
        } label: {
            Label {
                Text(
                    "Refresh",
                    bundle: .toolkitModule,
                    comment: "A label for a button to refresh map area content."
                )
            } icon: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .font(.subheadline)
        .fontWeight(.semibold)
        .buttonBorderShape(.capsule)
        .buttonStyle(.bordered)
    }
    
    @ViewBuilder private var noInternetFooter: some View {
        Label {
            noInternetFooterErrorMessage
        } icon: {
            Image(systemName: "wifi.exclamationmark")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder private var noInternetNoAreasView: some View {
        Backported.ContentUnavailableView(
            .noInternetConnectionErrorMessage,
            systemImage: "wifi.exclamationmark",
            description: noMapAreasErrorMessage
        ) {
            refreshPreplannedButton
        }
    }
    
    @ViewBuilder private var emptyPreplannedOfflineAreasView: some View {
        Backported.ContentUnavailableView(
            noMapAreas,
            systemImage: "arrow.down.circle",
            description: noOfflineMapAreasMessage
        ) {
            refreshPreplannedButton
        }
    }
    
    @ViewBuilder private var preplannedErrorView: some View {
        Backported.ContentUnavailableView(
            errorFetchingAreas,
            systemImage: "exclamationmark.triangle",
            description: errorFetchingAreasMessage
        ) {
            refreshPreplannedButton
        }
    }
    
    @ViewBuilder private var emptyOnDemandOfflineAreasView: some View {
        Backported.ContentUnavailableView(
            noMapAreas,
            systemImage: "arrow.down.circle",
            description: emptyOnDemandMessage
        ) {
            Button {
                isAddingOnDemandArea = true
            } label: {
                Label {
                    addMapArea
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
        }
    }
    
    @ViewBuilder private var offlineDisabledView: some View {
        Backported.ContentUnavailableView(
            offlineDisabled,
            systemImage: "exclamationmark.triangle",
            description: offlineDisabledMessage
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
    struct ContentUnavailableView<Actions: View>: View {
        let title: LocalizedStringResource
        let systemImage: String
        let description: LocalizedStringResource?
        let actions: () -> Actions
        
        init(
            _ title: LocalizedStringResource,
            systemImage name: String,
            description: LocalizedStringResource? = nil,
            @ViewBuilder actions: @escaping () -> Actions
        ) {
            self.title = title
            self.systemImage = name
            self.description = description
            self.actions = actions
        }
        
        init(
            _ title: LocalizedStringResource,
            systemImage name: String,
            description: LocalizedStringResource? = nil
        ) where Actions == EmptyView {
            self.title = title
            self.systemImage = name
            self.description = description
            self.actions = { EmptyView() }
        }
        
        var body: some View {
            if #available(iOS 17, *) {
                SwiftUI.ContentUnavailableView {
                    Label(title.key, systemImage: systemImage)
                } description: {
                    if let description {
                        Text(description)
                    }
                } actions: {
                    actions()
                }
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
                    actions()
                }
                .padding()
            }
        }
    }
}

private extension OfflineMapAreasView {
    var addMapArea: Text {
        .init(
            "Add Map Area",
            bundle: .toolkitModule,
            comment: "A label for a button to add a map area."
        )
    }
    
    var noInternetFooterErrorMessage: Text {
        .init(
            "No internet connection. Showing downloaded areas only.",
            bundle: .toolkitModule,
            comment: "An error message explaining that there is no internet connection and only downloaded areas are shown."
        )
    }
    
    var noMapAreasErrorMessage: LocalizedStringResource {
        .init(
            "Could not retrieve map areas for this map.",
            bundle: .toolkit,
            comment: "An error message explaining that map areas could not be retrieved for this map."
        )
    }
    
    var noOfflineMapAreasMessage: LocalizedStringResource {
        .init(
            "There are no map areas for this map.",
            bundle: .toolkit,
            comment: "A message explaining that there are no map areas for this map."
        )
    }
    
    var errorFetchingAreas: LocalizedStringResource {
        .init(
            "Error Fetching Map Areas",
            bundle: .toolkit,
            comment: "A label indicating that an error occurred while fetching map areas."
        )
    }
    
    var errorFetchingAreasMessage: LocalizedStringResource {
        .init(
            "An error occurred while fetching map areas.",
            bundle: .toolkit,
            comment: "An error message for when fetching map areas fails."
        )
    }
    
    var noMapAreas: LocalizedStringResource {
        .init(
            "No Map Areas",
            bundle: .toolkit,
            comment: "A label indicating that there are no map areas."
        )
    }
    
    var emptyOnDemandMessage: LocalizedStringResource {
        .init(
            "There are no map areas for this map. Tap the button below to get started.",
            bundle: .toolkit,
            comment: "A message explaining that there are no map areas for this map and to tap the button below to add a map area."
        )
    }
    
    var offlineDisabled: LocalizedStringResource {
        .init(
            "Offline Disabled",
            bundle: .toolkit,
            comment: "A label indicating that the map is offline disabled."
        )
    }
    
    var offlineDisabledMessage: LocalizedStringResource {
        .init(
            "The map is not enabled for offline use.",
            bundle: .toolkit,
            comment: "A message indicating that the map is not offline enabled."
        )
    }
}
