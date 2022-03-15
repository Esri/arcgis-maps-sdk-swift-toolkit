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
    /// - Parameter selectedFacilityID: Indicates the implicity selected facility based on the
    /// current viewpoint.
    /// - Parameter selectedSiteID: Indicates the implicity selected site based on the current
    /// viewpoint.
    init(
        isHidden: Binding<Bool>,
        _ selectedFacilityID: Binding<String?>,
        _ selectedSiteID: Binding<String?>
    ) {
        self.isHidden = isHidden
        _selectedFacilityID = selectedFacilityID
        _selectedSiteID = selectedSiteID
    }

    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isHidden: Binding<Bool>

    /// Indicates the implicity selected facility based on the current viewpoint.
    @Binding
    private var selectedFacilityID: String?

    /// Indicates the implicity selected site based on the current viewpoint.
    @Binding
    private var selectedSiteID: String?

    var body: some View {
        VStack {
            if floorFilterViewModel.sites.count == 1 {
                Facilities(
                    facilities: floorFilterViewModel.sites.first!.facilities,
                    isHidden: isHidden,
                    selectedFacilityID: $selectedFacilityID,
                    showSites: true
                )
            } else {
                Sites(
                    isHidden: isHidden,
                    selectedFacilityID: $selectedFacilityID,
                    selectedSiteID: $selectedSiteID,
                    sites: floorFilterViewModel.sites
                )
            }
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    struct Sites: View {
        /// The view model used by this selector.
        @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>

        /// A subset of `sites` that contain `searchPhrase`.
        var matchingSites: [FloorSite] {
            if searchPhrase.isEmpty {
                return sites
            }
            return sites.filter { floorSite in
                floorSite.name.lowercased().contains(searchPhrase.lowercased())
            }
        }

        /// A site filtering phrase entered by the user.
        @State
        var searchPhrase: String = ""

        /// Indicates the implicity selected facility based on the current viewpoint.
        @Binding
        var selectedFacilityID: String?

        /// Indicates the implicity selected site based on the current viewpoint.
        @Binding
        var selectedSiteID: String?

        /// Sites contained in a `FloorManager`.
        let sites: [FloorSite]

        /// The height of the scroll view's content.
        @State
        private var scrollViewContentHeight: CGFloat = .zero

        var body: some View {
            NavigationView {
                VStack {
                    TextField("Filter sites", text: $searchPhrase)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                    List(matchingSites) { (site) in
                        NavigationLink(
                            site.name,
                            tag: site.siteId,
                            selection: $selectedSiteID) {
                                Facilities(
                                    facilities: site.facilities,
                                    isHidden: isHidden,
                                    selectedFacilityID: $selectedFacilityID
                                )
                            }
                            .onTapGesture {
                                selectedSiteID = site.siteId
                                floorFilterViewModel.selection = .site(site)
                            }
                    }
                    .listStyle(.plain)
                    NavigationLink("All sites") {
                        Facilities(
                            facilities: sites.flatMap({ $0.facilities }),
                            isHidden: isHidden,
                            selectedFacilityID: $selectedFacilityID,
                            showSites: true
                        )
                    }
                    .padding([.top, .bottom], 4)
                }
                .navigationBarTitle(Text("Select a site"), displayMode: .inline)
            }
            .navigationViewStyle(.stack)
        }
    }
    
    /// A view displaying the facilities contained in a `FloorManager`.
    struct Facilities: View {
        /// `FloorFacility`s to be displayed by this view.
        let facilities: [FloorFacility]

        /// The view model used by this selector.
        @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>

        /// A subset of `facilities` that contain `searchPhrase`.
        var matchingFacilities: [FloorFacility] {
            if searchPhrase.isEmpty {
                return facilities
            }
            return facilities.filter { floorFacility in
                floorFacility.name.lowercased().contains(searchPhrase.lowercased())
            }
        }

        /// A facility filtering phrase entered by the user.
        @State
        var searchPhrase: String = ""

        /// Indicates the implicity selected facility based on the current viewpoint.
        @Binding
        var selectedFacilityID: String?

        /// Indicates if site names should be shown as subtitles to the facility.
        ///
        /// Used when the user selects "All sites".
        var showSites: Bool = false

        var body: some View {
            VStack {
                if !showSites, let siteName = facilities.first?.site?.name {
                    Text(siteName)
                        .fontWeight(.ultraLight)
                }
                TextField("Filter facilities", text: $searchPhrase)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
                ScrollViewReader { proxy in
                    List(matchingFacilities, id: \.facilityId) { facility in
                        Button {
                            floorFilterViewModel.selection = .facility(facility)
                            isHidden.wrappedValue.toggle()
                        } label: {
                            HStack {
                                Image(
                                    systemName: selectedFacilityID == facility.facilityId ? "circle.fill" : "circle"
                                )
                                VStack {
                                    Text(facility.name)
                                        .fontWeight(.regular)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if showSites, let siteName = facility.site?.name {
                                        Text(siteName)
                                            .fontWeight(.ultraLight)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onChange(of: selectedFacilityID) { facilityID in
                        guard let facility = floorFilterViewModel.facilities.first(where: { facility in
                            facility.facilityId == facilityID
                        }) else {
                            return
                        }
                        withAnimation {
                            proxy.scrollTo(
                                facility.facilityId,
                                anchor: .center
                            )
                        }
                    }
                }
            }
            .navigationBarTitle("Select a facility")
        }
    }
}
