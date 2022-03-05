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
    @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isHidden: Binding<Bool>

    @State
    var text: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter site name", text: $text)
                .border(.gray)
            if let selectedSite = floorFilterViewModel.selectedSite {
                Facilities(facilities: selectedSite.facilities, isHidden: isHidden)
            } else if floorFilterViewModel.sites.count == 1 {
                Facilities(
                    facilities: floorFilterViewModel.sites.first!.facilities,
                    isHidden: isHidden
                )
            } else {
                Sites(sites: floorFilterViewModel.sites, isHidden: isHidden)
            }
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    struct Sites: View {
        let sites: [FloorSite]
        var isHidden: Binding<Bool>
        
        @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel

        /// The height of the scroll view's content.
        @State
        private var scrollViewContentHeight: CGFloat = .zero

        var body: some View {
            NavigationView {
                VStack {
                    List(sites) { (site) in
                        NavigationLink(
                            site.name,
                            destination: Facilities(
                                facilities: site.facilities,
                                isHidden: isHidden
                            )
                        )
//                        .onTapGesture {
//                            floorFilterViewModel.selection = .site(site)
//                        }
//                        .selected(floorFilterViewModel.selectedSite == site)
                    }
                    .listStyle(.plain)
                    NavigationLink(
                        "All sites",
                        destination: Facilities(
                            facilities: sites.first!.facilities,
                            isHidden: isHidden
                        )
                    )
                    .padding([.top, .bottom], 4)
                }
                .navigationBarTitle(Text("Select a site…"), displayMode: .inline)
                .toolbar {
                    Button {
                        isHidden.wrappedValue.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
            }
        }
    }
    
    /// A view displaying the facilities contained in a `FloorManager`.
    struct Facilities: View {
        let facilities: [FloorFacility]
        var isHidden: Binding<Bool>
        
        @EnvironmentObject var floorFilterViewModel: FloorFilterViewModel
        
        /// The height of the scroll view's content.
        @State
        private var scrollViewContentHeight: CGFloat = .zero
        
        var body: some View {
            List(facilities) { facility in
                Button {
                    print(facility.name)
                    floorFilterViewModel.selection = .facility(facility)
                    isHidden.wrappedValue = true
                } label: {
                    Text(facility.name)
                        .fontWeight(
                            floorFilterViewModel.selectedFacility == facility ? .bold : .regular
                        )
                }
            }
            .navigationTitle("Select a facility")
            .listStyle(.plain)
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
