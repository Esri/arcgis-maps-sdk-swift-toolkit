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

struct UtilityNetworkAssociationFormElementView: View {
    @EnvironmentObject private var model: NavigationLayerModel
    
    /// <#Description#>
    let description: String
    
    /// <#Description#>
    let associationKindGroups: [AssociationKindGroup]
    
    /// <#Description#>
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            // TODO: InputHeader to replace following in final implementation --
            ///
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
            //
            // TODO: End InputHeader replacement section -----------------------
            
            // TODO: InputFooter to replace following in final implementation --
            ///
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            //
            // TODO: End InputFooter replacement section -----------------------
            
            FeatureFormGroupedContentView(
                content: associationKindGroups.map { group in
                    Button {
                        model.push(
                            title: group.name,
                            subtitle: group.presentingForm
                        ) {
                            AssociationKindGroupView(associationKindGroup: group)
                        }
                    } label: {
                        HStack {
                            Text(group.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Group {
                                Text(group.networkSourceGroups.flatMap( { $0.associations.compactMap { $0 } } ).count.formatted())
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(.secondary)
                        }
                        .contentShape(.rect)
                    }
                }
            )
        }
    }
}

extension UtilityNetworkAssociationFormElementView {
    struct Association: Identifiable {
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let fractionAlongEdge: Double?
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let selectionAction: (() -> Void)
        
        /// <#Description#>
        let terminalName: String?
    }
    
    struct AssociationView: View {
        var association: Association
        
        var body: some View {
            Button {
                association.selectionAction()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(association.name)
                            .lineLimit(1)
                        if let description = association.description {
                            Text(description)
                                .font(.caption2)
                        }
                    }
                    Spacer()
                    Group {
                        if let percent = association.fractionAlongEdge {
                            Text(percent.formatted(.percent))
                        } else if let terminal = association.terminalName {
                            Text("Terminal: \(terminal)")
                        }
                    }
                    .padding(2.5)
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(5)
                    .font(.caption2)
                }
            }
        }
    }
    
    struct AssociationKindGroup: Identifiable {
        /// <#Description#>
        let networkSourceGroups: [NetworkSourceGroup]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let presentingForm: String
    }
    
    struct AssociationKindGroupView: View {
        @EnvironmentObject private var model: NavigationLayerModel
        
        let associationKindGroup: AssociationKindGroup
        
        @State private var isExpanded = false
        
        var body: some View {
            List(associationKindGroup.networkSourceGroups) { group in
                Button {
                    model.push(
                        title: group.name,
                        subtitle: group.presentingForm
                    ) {
                        NetworkSourceGroupView(networkSourceGroup: group)
                    }
                } label: {
                    HStack {
                        Text(group.name)
                        Spacer()
                        Text(group.associations.count.formatted())
                    }
                }
                .listRowBackground(Color(uiColor: .tertiarySystemFill))
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    struct NetworkSourceGroup: Identifiable {
        /// <#Description#>
        let associations: [Association]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let presentingForm: String
    }
    
    struct NetworkSourceGroupView: View {
        let networkSourceGroup:  NetworkSourceGroup
        
        var body: some View {
            List(networkSourceGroup.associations) {
                AssociationView(association: $0)
                    .listRowBackground(Color(uiColor: .tertiarySystemFill))
            }
            .scrollContentBackground(.hidden)
        }
    }
}
