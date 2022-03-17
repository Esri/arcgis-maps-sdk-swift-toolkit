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
    init(isHidden: Binding<Bool>) {
        self.isHidden = isHidden
    }

    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject var viewModel: FloorFilterViewModel

    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isHidden: Binding<Bool>

    var body: some View {
        VStack {
            if viewModel.sites.count == 1 {
                Facilities(
                    facilities: viewModel.sites.first!.facilities,
                    isHidden: isHidden,
                    showSites: true
                )
            } else {
                Sites(
                    isHidden: isHidden,
                    sites: viewModel.sites
                )
            }
        }
    }

    /// A view displaying the sites contained in a `FloorManager`.
    struct Sites: View {
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel

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
                            tag: site,
                            selection: $viewModel.selectedSite
                        ) {
                            Facilities(
                                facilities: site.facilities,
                                isHidden: isHidden
                            )
                        }
                            .onTapGesture {
                                viewModel.setSite(
                                    site,
                                    zoomTo: true
                                )
                            }
                    }
                        .listStyle(.plain)
                    NavigationLink("All sites") {
                        Facilities(
                            facilities: sites.flatMap({ $0.facilities }),
                            isHidden: isHidden,
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
        @EnvironmentObject var viewModel: FloorFilterViewModel

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

        /// Indicates if site names should be shown as subtitles to the facility.
        ///
        /// Used when the user selects "All sites".
        var showSites: Bool = false

        /// Determines  if a given site is the one marked as selected in the view model.
        /// - Parameter facility: The facility of interest
        /// - Returns: `true` if the facility is marked as selected in the view model.
        func facilityIsSelected(_ facility: FloorFacility) -> Bool {
            return facility.facilityId ==
                viewModel.selectedFacility?.facilityId
        }

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
                            viewModel.setFacility(
                                facility,
                                zoomTo: true
                            )
                            isHidden.wrappedValue.toggle()
                        } label: {
                            HStack {
                                Image(
                                    systemName:
                                        facilityIsSelected(facility) ? "circle.fill" : "circle"
                                )
                                VStack {
                                    Text(facility.name)
                                    .fontWeight(.regular)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    if showSites, let siteName = facility.site?.name {
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
                        .onChange(of: viewModel.selectedFacility) {
                            guard let facility = $0 else {
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
