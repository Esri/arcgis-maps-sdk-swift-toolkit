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
        @Binding var conditions: [String]
        
        var body: some View {
            Form {
                Section {
                    Picker(LocalizedStringResource.field.key, selection: .constant(1)) {
                        
                    }
                    Picker(LocalizedStringResource.condition.key, selection: .constant(1)) {
                        
                    }
                    TextField(LocalizedStringResource.value.key, text: .constant(""))
                } header: {
                    HStack {
                        Text(
                            "Condition 1",
                            bundle: .toolkitModule,
                            comment: "A label for the nth feature filtering condition."
                        )
                        .textCase(.none)
                        Spacer()
                        Button {
                            
                        } label: {
                            Label {
                                Text(
                                    "Condition 1 options",
                                    bundle: .toolkitModule,
                                    comment: "Options for the nth condition"
                                )
                            } icon: {
                                Image(systemName: "ellipsis")
                            }
                            .labelStyle(.iconOnly)
                        }
                        .foregroundStyle(.secondary)
                        .contextMenu {
                            Button(role: .destructive) {
                                conditions.removeAll() /* TODO: Remove only current condition */
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
                        }
                    }
                }
            }
        }
    }
}
