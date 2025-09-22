// Copyright 2025 Esri
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

struct UtilityAssociationFeatureCandidatesView: View {
    /// The navigation path for the navigation stack presenting this view.
    @Environment(\.navigationPath) var navigationPath
    
    /// <#Description#>
    let element: UtilityAssociationsFormElement
    /// <#Description#>
    let filter: UtilityAssociationsFilter
    /// <#Description#>
    let source: UtilityAssociationFeatureSource
    
    /// <#Description#>
    @State private var candidates: [UtilityAssociationFeatureCandidate] = []
    
    var body: some View {
        List(candidates, id: \.title) { candidate in
            Button {
                navigationPath?.wrappedValue.append(
                    FeatureFormView.NavigationPathItem.utilityAssociationCreationView(candidate, element, filter)
                )
            } label: {
                Text(candidate.title)
            }
        }
        .task {
            let parameters = QueryParameters()
            parameters.whereClause = "1=1"
            candidates = (try? await source.queryFeatures(parameters: parameters).candidates) ?? []
        }
    }
}
