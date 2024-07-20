// Copyright 2022 Esri
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

extension SiteAndFacilitySelector {
    /// <#Description#>
    @MainActor
    struct Header: View {
        /// <#Description#>
        @Binding var allSitesIsSelected: Bool
        
        @Binding var isPresented: Bool
        
        /// <#Description#>
        @Binding var query: String
        
        /// A Boolean value indicating whether the user pressed the back button in the header.
        ///
        /// This allows for browsing the site list while keeping the current selection unmodified.
        @Binding var userDidBackOutToSiteList: Bool
        
        /// The view model used by the `SiteAndFacilitySelector`.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// <#Description#>
        @FocusState var textFieldIsFocused: Bool
        
        /// <#Description#>
        let multipleSitesAreAvailable: Bool
        
        var body: some View {
            VStack {
                upperHeader
                lowerHeader
            }
        }
        
        /// <#Description#>
        var lowerHeader: some View {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(facilityListIsVisible ? String.filterFacilities : String.filterSites, text: $query)
                        .disableAutocorrection(true)
                        .focused($textFieldIsFocused)
                        .keyboardType(.alphabet)
                    if textFieldIsFocused {
                        Button {
                            query.removeAll()
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .renderingMode(.template)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                if textFieldIsFocused {
                    Button(String.cancel) {
                        query.removeAll()
                        textFieldIsFocused = false
                    }
                }
            }
        }
        
        /// <#Description#>
        var upperHeader: some View {
            HStack {
                Button {
                    userDidBackOutToSiteList = true
                } label: {
                    Image(systemName: "chevron.left")
                }
                .opacity(backButtonIsVisible ? 1 : 0)
                Spacer()
                Group {
                    if allSitesIsSelected {
                        Text(String.allSites)
                    } else if facilityListIsVisible {
                        Text(viewModel.selection?.site?.name ?? String.selectAFacility)
                    } else {
                        Text.sites
                    }
                }
                .font(.title3)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
        }
        
        /// <#Description#>
        var backButtonIsVisible: Bool {
            facilityListIsVisible
            && multipleSitesAreAvailable
        }
        
        /// <#Description#>
        var facilityListIsVisible: Bool {
            (allSitesIsSelected
            || viewModel.selection != .none
            || !multipleSitesAreAvailable)
            && !userDidBackOutToSiteList
        }
    }
}

/// A view which allows selection of sites and facilities represented in a `FloorManager`.
///
/// If the floor aware data contains only one site, the selector opens directly to the facilities list.
@MainActor
struct SiteAndFacilitySelector: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isPresented: Bool
    
    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// <#Description#>
    @State private var allSitesIsSelected = false
    
    /// <#Description#>
    @State private var query = ""
    
    /// A Boolean value indicating whether the user pressed the back button in the header.
    ///
    /// This allows for browsing the site list while keeping the current selection unmodified.
    @State private var userDidBackOutToSiteList = false
    
    var body: some View {
        VStack {
            Header(allSitesIsSelected: $allSitesIsSelected, isPresented: $isPresented, query: $query, userDidBackOutToSiteList: $userDidBackOutToSiteList, multipleSitesAreAvailable: multipleSitesAreAvailable)
                .padding([.leading, .top, .trailing])
            if (userDidBackOutToSiteList || viewModel.selection == .none) && multipleSitesAreAvailable {
                SiteList(allSitesIsSelected: $allSitesIsSelected, isPresented: $isPresented, query: $query, userDidBackOutToSiteList: $userDidBackOutToSiteList)
            } else {
                FacilityList(
                    isPresented: $isPresented,
                    query: $query,
                    usesAllSitesStyling: allSitesIsSelected,
                    facilities: allSitesIsSelected ? viewModel.facilities : viewModel.selection?.site?.facilities ?? viewModel.facilities
                )
            }
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    @MainActor
    struct SiteList: View {
        /// <#Description#>
        @Binding var allSitesIsSelected: Bool
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        @Binding var isPresented: Bool
        
        /// A site name filter phrase entered by the user.
        @Binding var query: String
        
        /// A Boolean value indicating whether the user pressed the back button in the header.
        ///
        /// This allows for browsing the site list while keeping the current selection unmodified.
        @Binding var userDidBackOutToSiteList: Bool
        
        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass: UserInterfaceSizeClass?
        
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// A subset of `sites` with names containing `query` or all `sites` if `query` is empty.
        var matchingSites: [FloorSite] {
            guard !query.isEmpty else {
                return viewModel.sites
            }
            return viewModel.sites.filter {
                $0.name.localizedStandardContains(query)
            }
        }
        
        /// A view with a filter-via-name field, a list of site names and an "All sites" button.
        var body: some View {
            VStack {
                if matchingSites.isEmpty {
                    if #available(iOS 17, *) {
                        ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
                    } else {
                        NoMatchesView()
                    }
                } else {
                    siteList
                }
                allSitesButton
            }
            .onAppear {
                allSitesIsSelected = false
            }
        }
        
        /// The "All sites" button.
        ///
        /// This button presents the facilities list in a special format where the facilities list
        /// shows every facility in every site within the floor manager.
        var allSitesButton: some View {
            Button {
                allSitesIsSelected = true
                userDidBackOutToSiteList = false
            } label: {
                Text(String.allSites)
            }
            .buttonStyle(.bordered)
            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
        }
        
        /// A view containing a list of the site names.
        ///
        /// If `AutomaticSelectionMode` mode is in use, items will automatically be
        /// selected/deselected.
        var siteList: some View {
            List(matchingSites) { site in
                Button(site.name) {
                    userDidBackOutToSiteList = false
                    viewModel.setSite(site)
                }
            }
            .listStyle(.plain)
        }
    }
    
    /// A view displaying the facilities contained in a `FloorManager`.
    @MainActor
    struct FacilityList: View {
        /// Allows the user to toggle the visibility of the site and facility selector.
        @Binding var isPresented: Bool
        
        /// A facility name filter phrase entered by the user.
        @Binding var query: String
        
        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass: UserInterfaceSizeClass?
        
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// When `true`, the facilities list will be display with all sites styling.
        let usesAllSitesStyling: Bool
        
        /// `FloorFacility`s to be displayed by this view.
        let facilities: [FloorFacility]
        
        /// A subset of `facilities` with names containing `query` or all `facilities` if
        /// `query` is empty.
        var matchingFacilities: [FloorFacility] {
            guard !query.isEmpty else {
                return facilities
                    .sorted { $0.name < $1.name }
            }
            return facilities
                .filter { $0.name.localizedStandardContains(query) }
                .sorted { $0.name < $1.name  }
        }
        
        var body: some View {
            Group {
                if matchingFacilities.isEmpty {
                    if #available(iOS 17, *) {
                        ContentUnavailableView(String.noMatchesFound, systemImage: "building")
                    } else {
                        NoMatchesView()
                    }
                } else {
                    facilityList
                }
            }
        }
        
        /// Displays a list of facilities matching the filter criteria as determined by
        /// `matchingFacilities`.
        ///
        /// If a certain facility is indicated as selected by the view model, it will have a
        /// slightly different appearance.
        ///
        /// If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
        /// selected item.
        var facilityList: some View {
            ScrollViewReader { proxy in
                List(matchingFacilities, id: \.id) { facility in
                    VStack {
                        Text(facility.name)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        if usesAllSitesStyling, let siteName = facility.site?.name {
                            Text(siteName)
                                .font(.caption)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                        }
                    }
                    .contentShape(Rectangle())
                    .listRowBackground(facility.id == viewModel.selection?.facility?.id ? Color.secondary.opacity(0.5) : Color.clear)
                    .onTapGesture {
                        viewModel.setFacility(facility, zoomTo: true)
                        if horizontalSizeClass == .compact {
                            isPresented = false
                        }
                    }
                }
                .listStyle(.plain)
                .onChange(of: viewModel.selection) { _ in
                    if let floorFacility = viewModel.selection?.facility {
                        withAnimation {
                            proxy.scrollTo(
                                floorFacility.id
                            )
                        }
                    }
                }
            }
        }
    }
}

extension SiteAndFacilitySelector {
    /// <#Description#>
    var multipleSitesAreAvailable: Bool {
        viewModel.sites.count > 1
    }
}

extension SiteAndFacilitySelector.SiteList {
    /// The selected site as reflected in the `SiteAndFacilitySelector`.
    ///
    /// Note that the selection state can differ from the selection state of the view model.
    /// See `userBackedOutOfSelectedSite` for further explanation.
    var selectedSite: Binding<FloorSite?> {
        .init(
            get: {
                userDidBackOutToSiteList ? nil : viewModel.selection?.site
            },
            set: { newSite in
                guard let newSite = newSite else { return }
                userDidBackOutToSiteList = false
                viewModel.setSite(newSite, zoomTo: true)
            }
        )
    }
}

/// Displays text "No matches found".
private struct NoMatchesView: View {
    var body: some View {
        Text(String.noMatchesFound)
            .frame(maxHeight: .infinity)
    }
}

private extension String {
    static var allSites: Self {
        .init(
            localized: "All sites",
            bundle: .toolkitModule,
            comment: "A reference to all of the sites defined in a floor aware map."
        )
    }
    
    /// <#Description#>
    static var filterFacilities: Self {
        .init(
            localized: "Filter facilities",
            bundle: .toolkitModule,
            comment: """
                A field allowing the user to filter a list of facilities by name. A
                facility contains one or more levels in a floor-aware map or scene.
                """
        )
    }
    
    /// <#Description#>
    static var filterSites: Self {
        .init(
            localized: "Filter sites",
            bundle: .toolkitModule,
            comment: """
                 A field allowing the user to filter a list of sites by name. A site
                 contains one or more facilities in a floor-aware map or scene.
                 """
        )
    }
    
    /// A statement that no sites or facilities with names matching a filter phrase were found.
    static var noMatchesFound: Self {
        .init(
            localized: "No matches found.",
            bundle: .toolkitModule,
            comment: "A statement that no sites or facilities with names matching a filter phrase were found."
        )
    }
    
    /// <#Description#>
    static var selectAFacility: Self {
        .init(
            localized: "Select a facility",
            bundle: .toolkitModule,
            comment: """
                 A label directing the user to select a facility. A facility contains one
                 or more levels in a floor-aware map or scene.
                 """
        )
    }
}

private extension Text {
    /// A label in reference to all of the sites in a floor-aware map or scene.
    static var sites: Self {
        .init(
            "Sites",
            bundle: .toolkitModule,
            comment: "A label in reference to all of the sites in a floor-aware map or scene."
        )
    }
}
