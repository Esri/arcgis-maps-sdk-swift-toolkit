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
    let groups: [Group]
    
    /// <#Description#>
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                }
            }
            Text(description)
                .font(.caption)
            List {
                ForEach(groups) { group in
                    Section {
                        GroupView(group: group)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

extension UtilityNetworkAssociationFormElementView {
    struct Association: Identifiable {
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let icon: UIImage?
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
    }
    
    struct AssociationView: View {
        let association: Association
        
        var body: some View {
            HStack {
                if let image = association.icon {
                    Image(uiImage: image)
                }
                VStack(alignment: .leading) {
                    Text(association.name)
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
                .font(.caption2)
            }
        }
    }
    
    struct Group: Identifiable {
        /// <#Description#>
        let associations: [Association]
        
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
    }
    
    struct GroupView: View {
        let group: Group
        
        @State private var isExpanded = true
        
        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(group.associations) { association in
                    AssociationView(association: association)
                }
            } label: {
                VStack(alignment: .leading) {
                    Text(group.name)
                    if let description = group.description {
                        Text(description)
                            .font(.caption)
                    }
                }
            }
        }
    }
}
