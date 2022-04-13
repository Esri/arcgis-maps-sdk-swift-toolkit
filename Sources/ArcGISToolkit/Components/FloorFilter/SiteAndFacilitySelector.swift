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
    /// Creates a `SiteAndFacilitySelector`
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
        
        /// Indicates whether the view model should be notified of the selection update.
        @State private var updateViewModel = true
        
        /// Indicates that the keyboard is animating and some views may require reload.
        @State private var keyboardAnimating = false
        
        /// A site name filter phrase entered by the user.
        @State private var searchPhrase: String = ""
        
        /// A local record of the site selected in the view model.
        ///
        /// As the view model's selection will change to `.facility(FloorFacility)` and
        /// `.level(FloorLevel)` over time, this is needed to keep track of the site at the top of the
        /// hierarchy to keep the site selection persistent in the navigation view.
        @State private var selectedSite: FloorSite? {
            didSet {
                if updateViewModel, let site = selectedSite {
                    viewModel.setSite(site, zoomTo: true)
                }
                updateViewModel = true
            }
        }
        
        /// Sites contained in a `FloorManager`.
        let sites: [FloorSite]
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>
        
        /// A subset of `sites` with names containing `searchPhrase` or all `sites` if
        /// `searchPhrase` is empty.
        var matchingSites: [FloorSite] {
            if searchPhrase.isEmpty {
                return sites
            }
            return sites.filter {
                $0.name.lowercased().contains(searchPhrase.lowercased())
            }
        }
        
        var body: some View {
            siteListAndFilterView
                // Trigger a reload on keyboard frame changes for proper layout
                // across all devices.
                .opacity(keyboardAnimating ? 0.99 : 1.0)
                .navigationViewStyle(.stack)
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIResponder.keyboardWillChangeFrameNotification
                    )
                ) { _ in
                    withAnimation {
                        keyboardAnimating = true
                    }
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIResponder.keyboardDidChangeFrameNotification
                    )
                ) { _ in
                    withAnimation {
                        keyboardAnimating = false
                    }
                }
        }
        
        /// A view containing a filter-via-name field, a list of the site names and an "All sites" button.
        var siteListAndFilterView: some View {
            NavigationView {
                Group {
                    if matchingSites.isEmpty {
                        NoMatchesView()
                    } else {
                        siteListView
                    }
                }
                .searchable(
                    text: $searchPhrase,
                    placement: .navigationBarDrawer,
                    prompt: "Filter sites"
                )
                .keyboardType(.alphabet)
                .disableAutocorrection(true)
                .navigationBarTitle(
                    Text("Select a site"),
                    displayMode: .inline
                )
                .toolbar {
                    ToolbarItem {
                        CloseButton { isHidden.wrappedValue.toggle() }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink("All sites") {
                            FacilitiesList(
                                facilities: sites.flatMap({ $0.facilities }),
                                presentationStyle: .allSites,
                                isHidden: isHidden
                            )
                        }
                    }
                }
            }
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
                    selection: $selectedSite
                ) {
                    FacilitiesList(
                        facilities: site.facilities,
                        presentationStyle: .standard,
                        isHidden: isHidden
                    )
                }
                .onTapGesture {
                    selectedSite = site
                }
            }
            .listStyle(.plain)
            .onChange(of: viewModel.selection) { _ in
                // Setting the `updateViewModel` flag false allows
                // `selectedSite` to receive upstream updates from the view
                // model without republishing them back up to the view model.
                updateViewModel = false
                selectedSite = viewModel.selectedSite
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
        @State var searchPhrase: String = ""
        
        /// `FloorFacility`s to be displayed by this view.
        let facilities: [FloorFacility]
        
        /// The selected presentation style for the facility list.
        let presentationStyle: PresentationStyle
        
        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>
        
        /// A subset of `facilities` with names containing `searchPhrase` or all
        /// `facilities` if `searchPhrase` is empty.
        var matchingFacilities: [FloorFacility] {
            if searchPhrase.isEmpty {
                return facilities
            }
            return facilities.filter {
                $0.name.lowercased().contains(searchPhrase.lowercased())
            }
        }
        
        var body: some View {
            if presentationStyle == .singleSite {
                facilityListAndFilterView
            } else {
                facilityListAndFilterView
                    // Only apply navigation modifiers if this is displayed
                    // within a navigation view
                    .navigationBarTitle("Select a facility")
                    .toolbar {
                        CloseButton { isHidden.wrappedValue.toggle() }
                    }
            }
        }
        
        /// A view containing a label for the site name, a filter-via-name bar and a list of the facility names.
        var facilityListAndFilterView: some View {
            VStack {
                HStack {
                    if presentationStyle == .standard {
                        Text(facilities.first?.site?.name ?? "N/A")
                    } else if presentationStyle == .allSites {
                        Text("All sites")
                    } else if presentationStyle == .singleSite {
                        Text(facilities.first?.site?.name ?? "N/A")
                        Spacer()
                        CloseButton { isHidden.wrappedValue.toggle() }
                    }
                }
                if matchingFacilities.isEmpty {
                    NoMatchesView()
                } else {
                    facilityListView
                }
            }
            .searchable(
                text: $searchPhrase,
                placement: .navigationBarDrawer,
                prompt: "Filter facilities"
            )
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
        }
        
        /// Displays a list of facilities matching the filter criteria as determined by
        /// `matchingFacilities`.
        ///
        /// If a certain facility is indicated as selected by the view model, it will have a slighlty different
        /// appearance.
        ///
        /// If `AutomaticSelectionMode` mode is in use, this list will automatically scroll to the
        /// selected item.
        var facilityListView: some View {
            ScrollViewReader { proxy in
                List(matchingFacilities, id: \.id) { facility in
                    Button {
                        viewModel.setFacility(facility, zoomTo: true)
                        isHidden.wrappedValue.toggle()
                    } label: {
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
                    .selected(facility.id == viewModel.selectedFacility?.id)
                    .listRowSeparator(.hidden)
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
    }
}

/// Displays text "No matches found".
struct NoMatchesView: View {
    var body: some View {
        Text("No matches found")
            .frame(
                maxHeight: .infinity,
                alignment: .center
            )
    }
}

/// A custom button with an "X" enclosed within a circle to be used as a "close" button.
struct CloseButton: View {
    /// The button's action to be performed when tapped.
    var action: (() -> Void)
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle")
        }
    }
}
