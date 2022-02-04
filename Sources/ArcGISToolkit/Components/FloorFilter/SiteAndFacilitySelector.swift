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
    /// - Parameter floorFilterViewModel: The view model used by the `SiteAndFacilitySelector`.
    /// - Parameter isVisible: A binding used to dismiss the site selector.
    init(
        floorFilterViewModel: FloorFilterViewModel,
        isVisible: Binding<Bool>
    ) {
        self.floorFilterViewModel = floorFilterViewModel
        self.isVisible = isVisible
    }
    
    /// The view model used by the `SiteAndFacilitySelector`.
    @ObservedObject
    private var floorFilterViewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site and facility selector.
    private var isVisible: Binding<Bool>
    
    var body: some View {
        if let selectedSite = floorFilterViewModel.selectedSite {
            Facilities(facilities: selectedSite.facilities, isVisible: isVisible)
        } else if floorFilterViewModel.sites.count == 1 {
            Facilities(
                facilities: floorFilterViewModel.sites.first!.facilities,
                isVisible: isVisible
            )
        } else {
            Sites(sites: floorFilterViewModel.sites, isVisible: isVisible)
        }
    }
    
    /// A view displaying the sites contained in a `FloorManager`.
    struct Sites: View {
        let sites: [FloorSite]
        var isVisible: Binding<Bool>

        var body: some View {
            VStack(alignment: .leading) {
                Header(title: "Select a site…", isVisible: isVisible)
                Divider()
                ForEach(sites) { site in
                    Text(site.name)
                }
            }
            .esriBorder()
        }
    }

    /// A view displaying the facilities contained in a `FloorManager`.
    struct Facilities: View {
        let facilities: [FloorFacility]
        var isVisible: Binding<Bool>
        
        var body: some View {
            VStack(alignment: .leading) {
                Header(title: "Select a facility…", isVisible: isVisible)
                Divider()
                ForEach(facilities) { facility in
                    Text(facility.name)
                }
            }
            .esriBorder()
        }
    }
    
    /// The header for a site or facility selector.
    struct Header: View {
        let title: String
        var isVisible: Binding<Bool>
        
        var body: some View {
            HStack {
                Text(title)
                    .bold()
                Spacer()
                Button {
                    isVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: "xmark.circle", label: Text("Close"))
                }
            }
        }
    }
}
