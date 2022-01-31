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

/// The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building
/// in your application. It allows you to filter the floor plan data displayed in your `GeoView`
/// to a site, a facility (building) in the site, or a floor in the facility.
public struct FloorFilter: View {
    /// Creates a `FloorFilter`
    /// - Parameter viewModel: The view model used by the `FloorFilter`.
    public init(_ viewModel: FloorFilterViewModel) {
        self.viewModel = viewModel
    }
    
    /// The view model used by the `FloorFilter`.
    @ObservedObject
    private(set) var viewModel: FloorFilterViewModel
    
    /// Allows the user to toggle the visibility of the site selector.
    @State
    private var isSelectorVisible: Bool = false
    
    public var body: some View {
        HStack(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .esriBorder()
            } else {
                VStack {
                    Button {
                        isSelectorVisible.toggle()
                    } label: {
                        Image.init("Site", bundle: Bundle.module)
                    }
                }
                .esriBorder()
                if isSelectorVisible {
                    SiteSelector(
                        viewModel,
                        isSelectorVisible: $isSelectorVisible
                    )
                        .frame(width: 200)
                }
            }
        }
    }
}
