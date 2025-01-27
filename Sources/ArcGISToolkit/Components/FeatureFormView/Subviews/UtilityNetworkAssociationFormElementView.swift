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
            
            ForEach(associationKindGroups) { group in
                AssociationKindGroupView(associationKindGroup: group)
            }
        }
    }
}

extension UtilityNetworkAssociationFormElementView {
    struct Association: Identifiable {
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
    }
    
    struct AssociationView: View {
        var association: Association
        
        var body: some View {
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
                Button {
                    
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.plain)
                .font(.caption2)
            }
            .padding(.leading)
        }
    }
    
    struct AssociationKindGroup: Identifiable {
        /// <#Description#>
        let networkSourceGroups: [NetworkSourceGroup]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
    }
    
    struct AssociationKindGroupView: View {
        let associationKindGroup: AssociationKindGroup
        
        @State private var isExpanded = false
        
        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(associationKindGroup.networkSourceGroups) {
                    NetworkSourceGroupView(networkSourceGroup: $0)
                }
            } label: {
                HStack {
                    Text(associationKindGroup.name)
                    Spacer()
                    Text(associationKindGroup.networkSourceGroups.map({ $0.associations.count }).count.formatted())
                }
            }
        }
    }
    
    struct NetworkSourceGroup: Identifiable {
        /// <#Description#>
        let associations: [Association]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
    }
    
    struct NetworkSourceGroupView: View {
        let networkSourceGroup:  NetworkSourceGroup
        
        var body: some View {
            DisclosureGroup {
                ForEach(networkSourceGroup.associations) {
                    AssociationView(association: $0)
                }
            } label: {
                HStack {
                    Text(networkSourceGroup.name)
                    Spacer()
                    Text(networkSourceGroup.associations.count.formatted())
                }
            }
            .padding(.leading)
        }
    }
}
