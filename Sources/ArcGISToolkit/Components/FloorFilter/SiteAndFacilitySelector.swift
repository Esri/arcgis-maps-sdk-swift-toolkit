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
struct SiteAndFacilitySelector: View {
    /// Creates a `SiteAndFacilitySelector`.
    /// - Parameter isHidden: A binding used to dismiss the site selector.
    init(isHidden: Binding<Bool>) {
        self.isHidden = isHidden
    }
    
    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isHidden: Binding<Bool>
    
    var body: some View {
        NavigationStack {
            Group {
                // If there's more than one site
                if viewModel.sites.count > 1 {
                    // Show the list of sites for site selection
                    SitesList(isHidden: isHidden)
                } else {
                    // Otherwise there're no sites or only one site, show the list of facilities
                    FacilitiesList(
                        usesAllSitesStyling: false,
                        facilities: viewModel.facilities,
                        isHidden: isHidden
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton { isHidden.wrappedValue.toggle() }
                }
            }
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    struct SitesList: View {
        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass: UserInterfaceSizeClass?
        
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// A site name filter phrase entered by the user.
        @State private var query: String = ""
        
        /// A Boolean value indicating whether the user pressed the back button in the navigation stack.
        ///
        /// This allows for programatic navigation back to the list of sites without clearing the view model's
        /// selection. Leaving the view model's selection unmodified keeps the level selector visible.
        /// visible.
        @State private var userBackedOutOfSelectedSite = false
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>
        
        /// A subset of `sites` with names containing `searchPhrase` or all `sites` if
        /// `searchPhrase` is empty.
        var matchingSites: [FloorSite] {
            guard !query.isEmpty else {
                return viewModel.sites
            }
            return viewModel.sites.filter {
                $0.name.localizedStandardContains(query)
            }
        }
        
        /// The selected site as reflected in the state of the navigation stack.
        ///
        /// Note that the selection state of the navigation stack can differ from the selection state of the
        /// view model. See `userBackedOutOfSelectedSite` for further explanation.
        var selectedSite: Binding<FloorSite?> {
            .init(
                get: {
                    userBackedOutOfSelectedSite ? nil : viewModel.selection?.site
                },
                set: { newSite in
                    guard let newSite = newSite else { return }
                    userBackedOutOfSelectedSite = false
                    viewModel.setSite(newSite, zoomTo: true)
                }
            )
        }
        
        /// Make the navigation destination for an item in the site list.
        func makeNavigationDestination(site: FloorSite) -> some View {
            FacilitiesList(
                usesAllSitesStyling: false,
                facilities: site.facilities,
                isHidden: isHidden
            )
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        userBackedOutOfSelectedSite = true
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CloseButton { isHidden.wrappedValue.toggle() }
                }
            }
        }
        
        /// A view with a filter-via-name field, a list of site names and an "All sites" button.
        var body: some View {
            VStack {
                // If the filtered set of sites is empty
                if matchingSites.isEmpty {
                    // Show the "no matches" view
                    NoMatchesView()
                } else {
                    // Show the filtered set of sites
                    siteListView
                }
                allSitesButton
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: String(
                    localized: "Filter sites",
                    bundle: .toolkitModule,
                    comment: """
                             A field allowing the user to filter a list of sites by name. A site
                             contains one or more facilities in a floor-aware map or scene.
                             """
                )
            )
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .navigationTitle(
                String(
                    localized: "Sites",
                    bundle: .toolkitModule,
                    comment: "A label in reference to all of the sites in a floor-aware map or scene."
                )
            )
        }
        
        /// The "All sites" button.
        ///
        /// This button presents the facilities list in a special format where the facilities list
        /// shows every facility in every site within the floor manager.
        var allSitesButton: some View {
            NavigationLink {
                FacilitiesList(
                    usesAllSitesStyling: true,
                    facilities: viewModel.sites.flatMap(\.facilities),
                    isHidden: isHidden
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CloseButton { isHidden.wrappedValue.toggle() }
                    }
                }
            } label: {
                Text(
                    "All sites",
                    bundle: .toolkitModule,
                    comment: "A reference to all of the sites defined in a floor aware map."
                )
            }
            .buttonStyle(.bordered)
            .padding(.bottom, horizontalSizeClass == .compact ? 5 : 0)
        }
        
        /// A view containing a list of the site names.
        ///
        /// If `AutomaticSelectionMode` mode is in use, items will automatically be
        /// selected/deselected.
        var siteListView: some View {
            Group {
                if #available(iOS 17.0, *) {
                    List(matchingSites) { site in
                        Button(site.name) {
                            viewModel.setSite(site)
                        }
                    }
                    .navigationDestination(item: selectedSite) { site in
                        makeNavigationDestination(site: site)
                    }
                } else {
                    List(matchingSites, selection: selectedSite) { site in
                        Text(site.name)
                    }
                    .navigationDestination(
                        isPresented: Binding {
                            selectedSite.wrappedValue != nil
                        } set: { isPresented in
                            if !isPresented {
                                viewModel.clearSelection()
                            }
                        },
                        destination: {
                            if let selectedSite = viewModel.selection?.site {
                                makeNavigationDestination(site: selectedSite)
                            }
                        }
                    )
                }
            }
            .listStyle(.plain)
            .onChange(of: viewModel.selection) { _ in
                userBackedOutOfSelectedSite = false
            }
        }
    }
    
    /// A view displaying the facilities contained in a `FloorManager`.
    struct FacilitiesList: View {
        @Environment(\.horizontalSizeClass)
        private var horizontalSizeClass: UserInterfaceSizeClass?
        
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// A facility name filter phrase entered by the user.
        @State var query: String = ""
        
        /// When `true`, the facilities list will be display with all sites styling.
        let usesAllSitesStyling: Bool
        
        /// `FloorFacility`s to be displayed by this view.
        let facilities: [FloorFacility]
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>
        
        /// A subset of `facilities` with names containing `searchPhrase` or all
        /// `facilities` if `searchPhrase` is empty.
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
                    NoMatchesView()
                } else {
                    facilityListView
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: String(
                    localized: "Filter facilities",
                    bundle: .toolkitModule,
                    comment: """
                             A field allowing the user to filter a list of facilities by name. A
                             facility contains one or more levels in a floor-aware map or scene.
                             """
                )
            )
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .navigationTitle(
                usesAllSitesStyling ?
                String(
                    localized: "All sites",
                    bundle: .toolkitModule,
                    comment: "A reference to all of the sites defined in a floor aware map."
                ) :
                viewModel.selection?.site?.name ?? String(
                    localized: "Select a facility",
                    bundle: .toolkitModule,
                    comment: """
                             A label directing the user to select a facility. A facility contains one
                             or more levels in a floor-aware map or scene.
                             """
                )
            )
        }
        
        /// Displays a list of facilities matching the filter criteria as determined by
        /// `matchingFacilities`.
        ///
        /// If a certain facility is indicated as selected by the view model, it will have a
        /// slightly different appearance.
        ///
        /// If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
        /// selected item.
        var facilityListView: some View {
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
                            isHidden.wrappedValue.toggle()
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

/// Displays text "No matches found".
private struct NoMatchesView: View {
    var body: some View {
        Text(
            "No matches found.",
            bundle: .toolkitModule,
            comment: "A statement that no sites or facilities with names matching a filter phrase were found."
        )
        .frame(maxHeight: .infinity)
    }
}

/// A custom button with an "X" enclosed within a circle to be used as a "close" button.
private struct CloseButton: View {
    /// The button's action to be performed when tapped.
    var action: (() -> Void)
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle")
        }
    }
}
