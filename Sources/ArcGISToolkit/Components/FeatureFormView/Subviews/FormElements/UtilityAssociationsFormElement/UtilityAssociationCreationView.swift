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

struct UtilityAssociationCreationView: View {
    /// The navigation path for the navigation stack presenting this view.
    @Environment(\.navigationPath) var navigationPath
    
    /// <#Description#>
    let candidate: UtilityAssociationFeatureCandidate
    /// <#Description#>
    let element: UtilityAssociationsFormElement
    /// <#Description#>
    let filter: UtilityAssociationsFilter
    
    /// <#Description#>
    @State private var isAddingAssociation = false
    
    var body: some View {
        List {
            Button {
                isAddingAssociation = true
            } label: {
                Text(
                    "Add",
                    bundle: .toolkitModule,
                    comment: "A label for a button to add a new utility association."
                )
            }
            .disabled(isAddingAssociation)
        }
        .task(id: isAddingAssociation) {
            guard isAddingAssociation else { return }
            defer { isAddingAssociation = false }
            do {
                try await element.addAssociation(feature: candidate.feature, filter: filter)
                navigationPath?.wrappedValue.removeLast(3)
            } catch {
                #warning("Logger needed")
                print(error.localizedDescription)
            }
        }
    }
}
