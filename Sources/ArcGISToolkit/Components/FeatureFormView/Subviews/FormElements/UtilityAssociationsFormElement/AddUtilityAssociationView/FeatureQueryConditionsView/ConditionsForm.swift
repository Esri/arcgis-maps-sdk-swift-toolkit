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
    struct ConditionsForm: View {
        @Environment(FeatureFormView.UtilityAssociationNetworkSourcesView.Model.self) private var addUtilityAssociationViewModel
        
        var body: some View {
            addConditionButton
            Form {
                ForEach(Array(addUtilityAssociationViewModel.featureQueryConditions.enumerated()), id: \.offset) { offset, _ in
                    ConditionConfigurationSection(sectionNumber: offset + 1)
                }
            }
        }
        
        var addConditionButton: some View {
            Button {
                withAnimation {
                    addUtilityAssociationViewModel.featureQueryConditions.append("")
                }
            } label: {
                Label {
                    Text(
                        "Add Condition",
                        bundle: .toolkitModule,
                        comment: "Label for a button to add a new query condition."
                    )
                    .textCase(.none)
                } icon: {
                    Image(systemName: "plus.circle.fill")
                }
                .padding(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ConditionConfigurationSection: View {
    let sectionNumber: Int
    
    @Environment(FeatureFormView.UtilityAssociationNetworkSourcesView.Model.self) private var addUtilityAssociationViewModel
    
    var body: some View {
        Section {
            Picker(LocalizedStringResource.field.key, selection: .constant(1)) {
                
            }
            Picker(LocalizedStringResource.condition.key, selection: .constant(1)) {
                
            }
            TextField(LocalizedStringResource.value.key, text: .constant(""))
        } header: {
            HStack {
                Text(
                    "Condition \(sectionNumber)",
                    bundle: .toolkitModule,
                    comment: "A label for the nth feature filtering condition."
                )
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        withAnimation {
                            var conditions = addUtilityAssociationViewModel.featureQueryConditions
                            conditions.remove(at: sectionNumber - 1)
                            addUtilityAssociationViewModel.featureQueryConditions = conditions
                        }
                    } label: {
                        Label {
                            Text(
                                "Remove condition",
                                bundle: .toolkitModule,
                                comment: "Remove the feature filtering condition."
                            )
                        } icon: {
                            Image(systemName: "trash")
                        }
                    }
                } label: {
                    Label {
                        Text(
                            "Condition \(sectionNumber) options",
                            bundle: .toolkitModule,
                            comment: "Options for the nth condition"
                        )
                    } icon: {
                        Image(systemName: "ellipsis")
                    }
                    .tint(.secondary)
                    .labelStyle(.iconOnly)
                }
            }
            .textCase(.none)
        }
    }
}
