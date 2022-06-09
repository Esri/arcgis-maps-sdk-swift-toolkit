// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

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
        if viewModel.sites.count == 1 {
            FacilitiesList(
                facilities: viewModel.sites.first!.facilities,
                presentationStyle: .singleSite,
                isHidden: isHidden
            )
        } else {
            SitesList(
                sites: viewModel.sites,
                isHidden: isHidden
            )
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    struct SitesList: View {
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// A site name filter phrase entered by the user.
        @State private var query: String = ""
        
        /// Indicates whether a site entry should be considered "selected" in the list.
        @State var shouldAutoSelect = false
        
        /// Sites contained in a `FloorManager`.
        let sites: [FloorSite]
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>
        
        /// A subset of `sites` with names containing `searchPhrase` or all `sites` if
        /// `searchPhrase` is empty.
        var matchingSites: [FloorSite] {
            guard !query.isEmpty else {
                return sites
            }
            return sites.filter {
                $0.name.localizedStandardContains(query)
            }
        }
        
        /// A view containing a filter-via-name field, a list of the site names and an "All sites" button.
        var body: some View {
            NavigationView {
                VStack {
                    TextField("Filter sites", text: $query)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                    if matchingSites.isEmpty {
                        NoMatchesView()
                    } else {
                        siteListView
                    }
                    NavigationLink("All Sites") {
                        FacilitiesList(
                            facilities: sites.flatMap(\.facilities),
                            presentationStyle: .allSites,
                            isHidden: isHidden
                        )
                    }
                    .padding([.vertical], 4)
                }
                .navigationTitle("Sites")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CloseButton { isHidden.wrappedValue.toggle() }
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
        
        /// A view containing a list of the site names.
        ///
        /// If `AutomaticSelectionMode` mode is in use, items will automatically be
        /// selected/deselected.
        var siteListView: some View {
            List(matchingSites) { site in
                NavigationLink(
                    site.name,
                    tag: site,
                    selection: Binding(
                        get: {
                            return shouldAutoSelect ? viewModel.selectedSite : nil
                        },
                        set: { newSite in
                            guard let newSite = newSite else { return }
                            viewModel.setSite(newSite, zoomTo: true)
                        }
                    )
                ) {
                    FacilitiesList(
                        facilities: site.facilities,
                        presentationStyle: .standard,
                        isHidden: isHidden
                    )
                    .onDisappear {
                        shouldAutoSelect = false
                    }
                }
            }
            .listStyle(.plain)
            .onChange(of: viewModel.selection) { _ in
                shouldAutoSelect = true
            }
        }
    }
    
    /// A view displaying the facilities contained in a `FloorManager`.
    struct FacilitiesList: View {
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel
        
        /// Presentation styles for the facility list.
        enum PresentationStyle {
            /// A specific site was selected and the body is presented within a navigation view.
            case standard
            /// The all sites button was selcted and the body is presented within a navigation view.
            case allSites
            /// Only one site exists and the body is not presented within a navigation view.
            case singleSite
        }
        
        /// A facility name filter phrase entered by the user.
        @State var query: String = ""
        
        /// `FloorFacility`s to be displayed by this view.
        let facilities: [FloorFacility]
        
        /// The selected presentation style for the facility list.
        let presentationStyle: PresentationStyle
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        @Binding var isHidden: Bool
        
        /// A subset of `facilities` with names containing `searchPhrase` or all
        /// `facilities` if `searchPhrase` is empty.
        var matchingFacilities: [FloorFacility] {
            guard !query.isEmpty else {
                return facilities
            }
            return facilities.filter {
                $0.name.localizedStandardContains(query)
            }
        }
        
        var body: some View {
            if presentationStyle == .singleSite {
                facilityListAndFilterView
            } else {
                facilityListAndFilterView
                    // Only apply navigation modifiers if this is displayed
                    // within a navigation view
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            CloseButton { isHidden.toggle() }
                        }
                    }
            }
        }
        
        /// A view containing a label for the site name, a filter-via-name bar and a list of the facility names.
        var facilityListAndFilterView: some View {
            VStack {
                if presentationStyle == .singleSite {
                    HStack {
                        Text(navigationTitle)
                        Spacer()
                        CloseButton { isHidden.toggle() }
                    }
                }
                TextField("Filter facilities", text: $query)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
                if matchingFacilities.isEmpty {
                    NoMatchesView()
                } else {
                    facilityListView
                }
            }
        }
        
        /// Displays a list of facilities matching the filter criteria as determined by
        /// `matchingFacilities`.
        ///
        /// If a certain facility is indicated as selected by the view model, it will have a slightly different
        /// appearance.
        ///
        /// If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
        /// selected item.
        var facilityListView: some View {
            ScrollViewReader { proxy in
                List(matchingFacilities, id: \.id) { facility in
                    Button {
                        viewModel.setFacility(facility, zoomTo: true)
                        isHidden.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "circle")
                                .symbolVariant(facility.id == viewModel.selectedFacility?.id ? .fill : .none)
                            VStack {
                                Text(facility.name)
                                    .fontWeight(.regular)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                if presentationStyle == .allSites,
                                   let siteName = facility.site?.name {
                                    Text(siteName)
                                        .fontWeight(.ultraLight)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .onChange(of: viewModel.selection) { _ in
                    if let floorFacility = viewModel.selectedFacility {
                        withAnimation {
                            proxy.scrollTo(
                                floorFacility.id,
                                anchor: .center
                            )
                        }
                    }
                }
            }
        }
        
        /// A title to be displayed at the top of facility list.
        private var navigationTitle: String {
            switch presentationStyle {
            case .allSites:
                return "All Sites"
            default:
                return viewModel.selectedSite?.name ?? "Select a facility"
            }
        }
    }
}

/// Displays text "No matches found".
private struct NoMatchesView: View {
    var body: some View {
        Text("No matches found")
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
