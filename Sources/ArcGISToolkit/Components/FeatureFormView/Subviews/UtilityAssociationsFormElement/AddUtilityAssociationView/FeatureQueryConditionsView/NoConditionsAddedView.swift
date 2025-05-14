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

extension FeatureQueryConditionsView {
    struct NoConditionsAddedView: View {
        @Binding var conditions: [String]
        
        var body: some View {
            ContentUnavailableView {
                Label {
                    Text(
                        "No conditions added",
                        bundle: .toolkitModule,
                        comment: "The status text when no conditions have been added."
                    )
                } icon: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            } description: {
                Text(
                    "Show features that meet all the conditions",
                    bundle: .toolkitModule,
                    comment: "A description of what using adding conditions can do."
                )
            } actions: {
                Button {
                    conditions.append("")
                } label: {
                    Label {
                        Text(
                            "Add Condition",
                            bundle: .toolkitModule,
                            comment: "A label for a button to add a feature filtering condition."
                        )
                    } icon: {
                        Image(systemName: "plus")
                    }
                    .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    @Previewable @State var conditions = [String]()
    
    FeatureQueryConditionsView.NoConditionsAddedView(conditions: $conditions)
}
