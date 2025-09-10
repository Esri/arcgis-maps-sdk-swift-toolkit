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

import SwiftUI

struct FeatureQueryConditionsView: View {
    @Environment(FeatureFormView.AddUtilityAssociationView.Model.self) private var addUtilityAssociationViewModel
    
    var body: some View {
//        NavigationLayer { _ in
            Group {
                if addUtilityAssociationViewModel.featureQueryConditions.isEmpty {
                    NoConditionsAddedView()
                } else {
                    ConditionsForm()
                }
            }
//            .navigationLayerTitle("Filter Features")
            .transition(.scale)
//        } headerTrailing: {
            Button {
                withAnimation {
                    addUtilityAssociationViewModel.featureQueryConditionsViewIsPresented = false
                }
            } label: {
                Text(
                    "Apply",
                    bundle: .toolkitModule,
                    comment: "A button label to apply the conditions added to the query."
                )
            }
//        }
#if os(visionOS)
        .background(Color(uiColor: .tertiarySystemGroupedBackground))
#else
        .background(Color(uiColor: .systemGroupedBackground))
#endif
        .transition(.move(edge: .bottom))
    }
}
