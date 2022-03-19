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
        if viewModel.sites.count == 1 {
            Facilities(
                facilities: viewModel.sites.first!.facilities,
                isHidden: isHidden,
                presentationStyle: .singleSite
            )
        } else {
            Sites(
                isHidden: isHidden,
                sites: viewModel.sites
            )
        }
    }

    /// A view displaying the sites contained in a `FloorManager`.
    struct Sites: View {
        /// The view model used by this selector.
        @EnvironmentObject var viewModel: FloorFilterViewModel

        /// Allows the user to toggle the visibility of the site and facility selector.
        var isHidden: Binding<Bool>

        /// Indicates that the keyboard is animating and some views may require reload.
        @State
        private var keyboardAnimating = false

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

        var body: some View {
            NavigationView {
                VStack {
                    TextField("Filter sites", text: $searchPhrase)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                    if matchingSites.isEmpty {
                        VStack {
                            Spacer()
                            Text("No matches found")
                            Spacer()
                        }
                    } else {
                        List(matchingSites) { site in
                            NavigationLink(
                                site.name,
                                tag: site,
                                selection: $viewModel.selectedSite
                            ) {
                                Facilities(
                                    facilities: site.facilities,
                                    isHidden: isHidden,
                                    presentationStyle: .standard
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
                    }
                    NavigationLink("All sites") {
                        Facilities(
                            facilities: sites.flatMap({ $0.facilities }),
                            isHidden: isHidden,
                            presentationStyle: .allSites
                        )
                    }
                        .padding([.vertical], 4)
                }
                    .navigationBarTitle(
                        Text("Select a site"),
                        displayMode: .inline
                    )
                    .navigationBarItems(trailing:
                        Button(action: {
                            isHidden.wrappedValue.toggle()
                        }, label: {
                            Image(systemName: "xmark.circle")
                        })
                    )
            }
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
    }

    /// A view displaying the facilities contained in a `FloorManager`.
    struct Facilities: View {
        /// Presentation styles for the facility list.
        enum PresentationStyle {
            /// A specific site was selected and the body is presented within a navigation view.
            case standard
            /// The all sites button was selcted and the body is presented within a navigation view.
            case allSites
            /// Only one site exists and the body is not presented within a navigation view.
            case singleSite
        }

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

        /// The selected presentation style for the facility list.
        let presentationStyle: PresentationStyle

        /// A facility filtering phrase entered by the user.
        @State
        var searchPhrase: String = ""

        /// Determines  if a given site is the one marked as selected in the view model.
        /// - Parameter facility: The facility of interest
        /// - Returns: `true` if the facility is marked as selected in the view model.
        func facilityIsSelected(_ facility: FloorFacility) -> Bool {
            return facility.facilityId ==
                viewModel.selectedFacility?.facilityId
        }

        var body: some View {
            if presentationStyle == .standard ||
                presentationStyle == .allSites {
                facilityFilterAndListView
                    // Only apply navigation modifiers if this is displayed
                    // within a navigation view
                    .navigationBarTitle("Select a facility")
                    .navigationBarItems(trailing: closeButtonView)
            } else {
                facilityFilterAndListView
            }
        }

        /// Closese the site and facility selector.
        var closeButtonView: some View {
            Button(action: {
                isHidden.wrappedValue.toggle()
            }, label: {
                Image(systemName: "xmark.circle")
            })
        }

        /// A view containing a label for the site name, a filter-via-name bar and a list of the facility names.
        var facilityFilterAndListView: some View {
            VStack {
                HStack {
                    if presentationStyle == .standard {
                        Text(facilities.first?.site?.name ?? "N/A")
                    } else if presentationStyle == .allSites {
                        Text("All sites")
                    } else if presentationStyle == .singleSite {
                        Text(facilities.first?.site?.name ?? "N/A")
                        Spacer()
                        closeButtonView
                    }
                }
                TextField("Filter facilities", text: $searchPhrase)
                    .keyboardType(.alphabet)
                    .disableAutocorrection(true)
                if matchingFacilities.isEmpty {
                    VStack {
                        Spacer()
                        Text("No matches found")
                        Spacer()
                    }
                } else {
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
            }
        }
    }
}
