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

struct SiteAndFacilitySelector: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isPresented: Bool
    
    /// The view model used by the `SiteAndFacilitySelector`.
    @EnvironmentObject private var model: FloorFilterViewModel
    
    @State private var navigationPath = NavigationPath()
    
    /// A Boolean value indicating if there are multiple sites. If there not
    /// multiple sites, then we go straight to the facilities list.
    private var hasMultipleSites: Bool { model.sites.count > 1 }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if model.sites.count > 1 {
                    SiteList(isPresented: $isPresented)
                } else {
                    FacilityList(isPresented: $isPresented, site: nil)
                }
            }
            .navigationDestination(for: FloorFacility.self) { facility in
                FacilityList(
                    isPresented: $isPresented,
                    site: model.showingFaciltiesFromAllSites ? nil : facility.site
                )
            }
        }
        .onAppear {
            guard hasMultipleSites, let facility = model.selection?.facility else {
                return
            }
            navigationPath.append(facility)
        }
        .frame(minWidth: 360, minHeight: 500)
    }
}

private struct SiteList: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isPresented: Bool

    /// The view model backing this view.
    @EnvironmentObject private var model: FloorFilterViewModel
    
    @State private var searchText = ""
    
    /// The filtered sites.
    var sites: [FloorSite] {
        guard !searchText.isEmpty else {
            return model.sites
        }
        return model.sites.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }
    
    var body: some View {
        VStack {
            if sites.isEmpty {
                ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
            } else {
                List(sites, id:\.id) { site in
                    NavigationLink {
                        FacilityList(isPresented: $isPresented, site: site)
                            .onAppear {
                                model.showingFaciltiesFromAllSites = false
                            }
                    } label: {
                        Text(site.name)
                            .lineLimit(1)
                    }
                }
                .listStyle(.plain)
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer,
            prompt: String.filterSites
        )
        .navigationTitle(String.sites)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DismissButton(kind: .cancel) {
                    isPresented = false
                }
            }
            ToolbarItem(placement: .bottomBar) {
                allSitesButton
            }
        }
    }
    
    @ViewBuilder var allSitesButton: some View {
        NavigationLink {
            FacilityList(isPresented: $isPresented, site: nil)
                .onAppear {
                    model.showingFaciltiesFromAllSites = true
                }
        } label: {
            Text(String.allSites)
        }
    }
}

private struct FacilityList: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isPresented: Bool

    /// The view model backing this view.
    @EnvironmentObject private var model: FloorFilterViewModel
    
    let site: FloorSite?
    @State private var searchText = ""
    
    /// The filtered facilities.
    var facilities: [FloorFacility] {
        let facilities = site?.facilities ?? model.facilities
        
        guard !searchText.isEmpty else {
            return facilities.sorted(using: KeyPathComparator(\.name))
        }
        return facilities
            .filter { $0.name.localizedStandardContains(searchText) }
            .sorted(using: KeyPathComparator(\.name))
    }
    
    var body: some View {
        VStack {
            if facilities.isEmpty {
                ContentUnavailableView(String.noMatchesFound, systemImage: "building.2")
            } else {
                ScrollViewReader { scrollView in
                    List(facilities, id:\.id) { facility in
                        Button {
                            model.setFacility(facility, zoomTo: true)
                            isPresented = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(facility.name)
                                    if model.showingFaciltiesFromAllSites {
                                        Text(facility.site?.name ?? "")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if facility.id == model.selection?.facility?.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.primary)
                                }
                            }
                            .contentShape(.rect)
                            .lineLimit(1)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .onChange(of: model.selection) {
                        guard let floorFacility = model.selection?.facility else {
                            return
                        }
                        withAnimation { scrollView.scrollTo(floorFacility.id) }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DismissButton(kind: .cancel) {
                    isPresented = false
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer,
            prompt: String.filterFacilities
        )
        .navigationTitle(String.selectAFacility)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension String {
    static var allSites: Self {
        .init(
            localized: "All Sites",
            bundle: .toolkitModule,
            comment: "A reference to all of the sites defined in a floor aware map."
        )
    }
    
    /// A field allowing the user to filter a list of facilities by name. A facility contains one or more levels in a floor-aware map or scene.
    static var filterFacilities: Self {
        .init(
            localized: "Filter facilities",
            bundle: .toolkitModule,
            comment: """
                A field allowing the user to filter a list of facilities by name. A
                facility contains one or more levels in a floor-aware map or scene.
                """
        )
    }
    
    /// A field allowing the user to filter a list of sites by name. A site contains one or more facilities in a floor-aware map or scene.
    static var filterSites: Self {
        .init(
            localized: "Filter sites",
            bundle: .toolkitModule,
            comment: """
                 A field allowing the user to filter a list of sites by name. A site
                 contains one or more facilities in a floor-aware map or scene.
                 """
        )
    }
    
    /// A statement that no sites or facilities with names matching a filter phrase were found.
    static var noMatchesFound: Self {
        .init(
            localized: "No matches found.",
            bundle: .toolkitModule,
            comment: "A statement that no sites or facilities with names matching a filter phrase were found."
        )
    }
    
    /// A label directing the user to select a facility. A facility contains one or more levels in a floor-aware map or scene.
    static var selectAFacility: Self {
        .init(
            localized: "Select a facility",
            bundle: .toolkitModule,
            comment: """
                 A label directing the user to select a facility. A facility contains one
                 or more levels in a floor-aware map or scene.
                 """
        )
    }
    
    /// A label directing the user to select a facility. A facility contains one or more levels in a floor-aware map or scene.
    static var sites: Self {
        .init(
            localized: "Sites",
            bundle: .toolkitModule,
            comment: "A label in reference to all of the sites in a floor-aware map or scene."
        )
    }
}
