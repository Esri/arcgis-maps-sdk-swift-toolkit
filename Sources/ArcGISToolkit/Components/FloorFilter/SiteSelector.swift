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
        self.showSiteList = showSiteSelector
    }

    private let viewModel: FloorFilterViewModel
    
    /// Binding allowing the user to toggle the visibility of the results list.
    private var showSiteList: Binding<Bool>

    // TODO: refactor if-else below.
    var body: some View {
        if !viewModel.sites.isEmpty {
            LazyVStack {
                HStack {
                    Text("Select a site...")
                        .bold()
                    Spacer()
                    Button {
                        showSiteList.wrappedValue.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                Rectangle()
                    .frame(height:1)
                    .foregroundColor(.secondary)
                ForEach(viewModel.sites) { site in
                    Text("\(site.name)")
                }
            }
            .esriBorder()
        } else {
            LazyVStack {
                HStack {
                    Text("Select a facility...")
                        .bold()
                    Spacer()
                    Button {
                        showSiteList.wrappedValue.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                Rectangle()
                    .frame(height:1)
                    .foregroundColor(.secondary)
                ForEach(viewModel.facilities) { facility in
                    Text("\(facility.name)")
                }
            }
            .esriBorder()
        }
    }
}
