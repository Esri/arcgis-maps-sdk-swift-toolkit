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

public struct FloorFilter: View {
    /// Creates a `FloorFilter`
    /// - Parameter content: The view shown in the floating panel.
    public init(_ floorFilterViewModel: FloorFilterViewModel) {
        self.viewModel = floorFilterViewModel
    }
    
    @ObservedObject
    private(set) var viewModel: FloorFilterViewModel
    
    @State
    private var showSiteSelector: Bool = false
    
    public var body: some View {
        HStack(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .esriBorder()
            } else {
                VStack {
                    //
                    // show levels and close button here
                    //
                    Button {
                        showSiteSelector.toggle()
                    } label: {
                        Image(uiImage: .site)
                    }
                }
                .esriBorder()
                if showSiteSelector {
                    SiteSelector(
                        viewModel,
                        showSiteSelector: $showSiteSelector
                    )
                        .frame(width: 200)
                }
            }
        }
    }
}
