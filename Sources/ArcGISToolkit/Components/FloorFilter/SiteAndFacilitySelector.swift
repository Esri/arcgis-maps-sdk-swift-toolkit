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
    @EnvironmentObject
    var floorFilterViewModel: FloorFilterViewModel

    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isHidden: Binding<Bool>

    var body: some View {
        if let selectedSite = floorFilterViewModel.selectedSite {
            FacilitiesView(facilities: selectedSite.facilities, isHidden: isHidden)
        } else if floorFilterViewModel.sites.count == 1 {
            FacilitiesView(
                facilities: floorFilterViewModel.sites.first!.facilities,
                isHidden: isHidden
            )
        } else {
            SitesView(sites: floorFilterViewModel.sites, isHidden: isHidden)
        }
    }

    /// A view displaying the sites contained in a `FloorManager`.
    struct SitesView: View {
        /// The floor sites.
        let sites: [FloorSite]

        /// Allows the user to toggle the visibility of the sites.
        var isHidden: Binding<Bool>

        /// The view model used by the `Sites`.
        @EnvironmentObject
        var floorFilterViewModel: FloorFilterViewModel

        /// The height of the scroll view's content.
        @State
        private var scrollViewContentHeight: CGFloat = .zero

        var body: some View {
            VStack(alignment: .center) {
                Header(title: "Select a site", isHidden: isHidden)
                Divider()
                ScrollView {
                    VStack {
                        ForEach(sites) { site in
                            HStack {
                                Text(site.name)
                                Spacer()
                            }
                            .onTapGesture {
                                floorFilterViewModel.selection = .site(site)
                            }
                            .padding(4)
                            .selected(floorFilterViewModel.selectedSite == site)
                        }
                    }
                    .onSizeChange {
                        scrollViewContentHeight = $0.height
                    }
                }
                .frame(maxHeight: scrollViewContentHeight)
            }
        }
    }

    /// A view displaying the facilities contained in a `FloorManager`.
    struct FacilitiesView: View {
        let facilities: [FloorFacility]
        var isHidden: Binding<Bool>

        @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

        /// The height of the scroll view's content.
        @State
        private var scrollViewContentHeight: CGFloat = .zero

        var body: some View {
            VStack(alignment: .leading) {
                Header(title: "Select a facility", isHidden: isHidden)
                Divider()
                ScrollView {
                    VStack {
                        ForEach(facilities) { facility in
                            HStack {
                                Text(facility.name)
                                Spacer()
                            }
                            .onTapGesture {
                                floorFilterViewModel.selection = .facility(facility)
                                isHidden.wrappedValue = true
                            }
                            .padding(4 )
                            .selected(floorFilterViewModel.selectedFacility == facility)
                        }
                    }
                    .onSizeChange {
                        scrollViewContentHeight = $0.height
                    }
                }
                .frame(maxHeight: scrollViewContentHeight)
            }
        }
    }

    /// The header for a site or facility selector.
    struct Header: View {
        let title: String
        var isHidden: Binding<Bool>

        var body: some View {
            HStack {
                Text(title)
                    .bold()
                Spacer()
                Button {
                    isHidden.wrappedValue.toggle()
                } label: {
                    Image(systemName: "xmark.circle")
                }
            }
        }
    }
}
