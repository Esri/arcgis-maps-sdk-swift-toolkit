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

/// A view which allows selection of sites and facilities represented in a `FloorManager`.
///
/// If the floor aware data contains only one site, the selector opens directly to the facilities list.
struct SiteAndFacilitySelector: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isPresented: Bool
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// A Boolean value indicating whether the user is typing into the text field.
    @FocusState var textFieldIsFocused: Bool
    
    /// A Boolean value indicating whether the user tapped the "All Sites" button.
    @State private var allSitesIsSelected = false
    
    /// The site or facility filter phrase.
    @State private var query = ""
    
    /// A Boolean value indicating whether the user pressed the back button in the header.
    ///
    /// This allows for browsing the site list while keeping the current selection unmodified.
    @State private var userDidBackOutToSiteList = false
    
    var body: some View {
        VStack {
            header
                .padding([.leading, .top, .trailing])
            if (facilityListIsVisible && matchingFacilities.isEmpty) || (!facilityListIsVisible && matchingSites.isEmpty) {
                Spacer()
                ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
                Spacer()
            } else if facilityListIsVisible {
                facilityList
                    .transition(.move(edge: .trailing))
            } else {
                siteList
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.default, value: facilityListIsVisible)
        .animation(.default, value: textFieldIsFocused)
        .clipped()
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
                Button {
                    viewModel.setFacility(facility, zoomTo: true)
                    if horizontalSizeClass == .compact {
                        isPresented = false
                    }
                } label: {
                    VStack {
                        Text(facility.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if allSitesIsSelected, let siteName = facility.site?.name {
                            Text(siteName)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .contentShape(.rect)
                .listRowBackground(facility.id == viewModel.selection?.facility?.id ? Color.secondary.opacity(0.5) : nil)
            }
#if !os(visionOS)
            .listStyle(.plain)
#endif
            .onChange(of: viewModel.selection) {
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
    
    /// The header at the top of the selector containing the navigation controls and text field.
    var header: some View {
        VStack {
            if !textFieldIsFocused {
                headerUpperHalf
                    .transition(.opacity)
            }
            headerLowerHalf
        }
    }
    
    /// The portion of the header containing the text field.
    var headerLowerHalf: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(facilityListIsVisible ? String.filterFacilities : String.filterSites, text: $query)
                    .disableAutocorrection(true)
                    .focused($textFieldIsFocused)
                    .keyboardType(.alphabet)
                    .onChange(of: facilityListIsVisible) {
                        query.removeAll()
                        textFieldIsFocused = false
                    }
                if textFieldIsFocused && !query.isEmpty {
                    XButton(.clear) {
                        query.removeAll()
                    }
                }
            }
            .padding(5)
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 10))
            if textFieldIsFocused {
                Button(String.cancel) {
                    query.removeAll()
                    textFieldIsFocused = false
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
    
    /// The portion of the header containing the navigation controls.
    var headerUpperHalf: some View {
        HStack {
            Button {
                userDidBackOutToSiteList = true
            } label: {
                Image(systemName: "chevron.left")
                    .padding(.toolkitDefault)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
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
            Spacer()
            XButton(.dismiss) {
                isPresented = false
            }
        }
        .font(.title3)
    }
    
    /// A view containing a list of the site names.
    ///
    /// If `AutomaticSelectionMode` mode is in use, items will automatically be
    /// selected/deselected.
    @ViewBuilder
    var siteList: some View {
        List(matchingSites) { site in
            Button(site.name) {
                userDidBackOutToSiteList = false
                viewModel.setSite(site)
            }
        }
#if !os(visionOS)
        .listStyle(.plain)
#endif
        .onAppear {
            allSitesIsSelected = false
        }
        Button {
            allSitesIsSelected = true
            userDidBackOutToSiteList = false
        } label: {
            Text(String.allSites)
        }
        .buttonStyle(.bordered)
        .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
        .transition(.move(edge: .bottom))
    }
}

extension SiteAndFacilitySelector {
    /// A Boolean value indicating whether the back button in the header navigations controls is visible..
    var backButtonIsVisible: Bool {
        facilityListIsVisible
        && multipleSitesAreAvailable
    }
    
    /// A Boolean value indicating whether the facility list is visible.
    var facilityListIsVisible: Bool {
        (allSitesIsSelected
         || viewModel.selection != .none
         || !multipleSitesAreAvailable)
        && !userDidBackOutToSiteList
    }
    
    /// A subset of `facilities` with names containing `query` or all `facilities` if
    /// `query` is empty.
    var matchingFacilities: [FloorFacility] {
        let facilities = allSitesIsSelected ? viewModel.facilities : viewModel.selection?.site?.facilities ?? viewModel.facilities
        guard !query.isEmpty else {
            return facilities
                .sorted { $0.name < $1.name }
        }
        return facilities
            .filter { $0.name.localizedStandardContains(query) }
            .sorted { $0.name < $1.name  }
    }
    
    /// A subset of `sites` with names containing `query` or all `sites` if `query` is empty.
    var matchingSites: [FloorSite] {
        guard !query.isEmpty else {
            return viewModel.sites
        }
        return viewModel.sites.filter {
            $0.name.localizedStandardContains(query)
        }
    }
    
    /// A Boolean value indicating whether the floor aware data contains more than one site.
    var multipleSitesAreAvailable: Bool {
        viewModel.sites.count > 1
    }
}

private extension String {
    static var allSites: Self {
        .init(
            localized: "All Sites",
            bundle: .toolkitModule,
            comment: "A reference to all of the sites defined in a floor aware map."
        )
    }
    
    /// A field allowing the user to filter a list of facilities by name. A facility contains one or more levels in a floor-aware map or scene.
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
    
    /// A field allowing the user to filter a list of sites by name. A site contains one or more facilities in a floor-aware map or scene.
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
    
    /// A label directing the user to select a facility. A facility contains one or more levels in a floor-aware map or scene.
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
