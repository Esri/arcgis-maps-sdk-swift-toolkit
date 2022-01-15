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

struct SiteSelector: View {
    /// Creates a `FloorFilter`
    /// - Parameter content: The view shown in the floating panel.
    public init(
        _ floorFilterViewModel: FloorFilterViewModel,
        showSiteSelector: Binding<Bool>
    ) {
        self.viewModel = floorFilterViewModel
        self.showSiteSelector = showSiteSelector
    }
    
    private let viewModel: FloorFilterViewModel
    
    /// Binding allowing the user to toggle the visibility of the results list.
    private var showSiteSelector: Binding<Bool>
    
    var body: some View {
        if viewModel.sites.count > 1 && !(viewModel.selectedSite == nil) {
            // Only show site list if there is more than one site
            // and the user has not yet selected a site.
            FloorFilterList(
                "Select a site...",
                sites: viewModel.sites,
                showSiteSelector: showSiteSelector
            )
        } else {
            FloorFilterList(
                "Select a facility...",
                facilities: viewModel.facilities,
                showSiteSelector: showSiteSelector
            )
        }
    }
    
    struct FloorFilterList: View {
        private let title: String
        private let sites: [FloorSite]?
        private let facilities: [FloorFacility]?
        
        /// Binding allowing the user to toggle the visibility of the results list.
        private var showSiteSelector: Binding<Bool>
        
        init(
            _ title: String,
            sites: [FloorSite],
            showSiteSelector: Binding<Bool>
        ) {
            self.title = title
            self.sites = sites
            facilities = []
            self.showSiteSelector = showSiteSelector
        }
        
        init(
            _ title: String,
            facilities: [FloorFacility],
            showSiteSelector: Binding<Bool>
        ) {
            self.title = title
            self.facilities = facilities
            sites = nil
            self.showSiteSelector = showSiteSelector
        }
        
        var body: some View {
//            NavigationView {
//            TODO: figure this navigation stuff out or at least get to a demo-able point
                LazyVStack {
                    HStack {
                        Text(title)
                            .bold()
                        Spacer()
                        Button {
                            showSiteSelector.wrappedValue.toggle()
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    Rectangle()
                        .frame(height:1)
                        .foregroundColor(.secondary)
                    ForEach(sites ?? []) { site in
//                        NavigationLink(
//                            destination: EmptyView()) {
                                Text(site.name)
//                            }
                    }
                    ForEach(facilities ?? []) { facility in
//                        NavigationLink(
//                            destination: EmptyView()) {
                                Text(facility.name)
//                            }
                    }
                }
//            .navigationBarTitle("Mountain Airport")
                .esriBorder()
            }
        }
//    }
}
