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
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                }
            }
            Text(description)
                .font(.caption)
            ForEach(groups) { group in
                Section {
                    GroupView(group: group)
                }
            }
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
        
        let object: ArcGISFeature
        
        let imageGenerationAction: (() async -> UIImage?)?
    }
    
    struct AssociationView: View {
        /// The view model for the form.
        @EnvironmentObject var model: FormViewModel
        
        var association: Association
        
        @State private var fallbackIcon: UIImage?
        
        var body: some View {
            HStack {
                if let image = association.icon {
                    Image(uiImage: image)
                } else if let fallbackIcon {
                    Image(uiImage: fallbackIcon)
                }
                VStack(alignment: .leading) {
                    Text(association.name)
                        .lineLimit(1)
                    if let description = association.description {
                        Text(description)
                            .font(.caption2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
            .onTapGesture {
                model.selectedAssociation = association.object
            }
            .task {
                if association.icon == nil,
                   let imageGenerationAction = association.imageGenerationAction,
                   let icon = await imageGenerationAction() {
                    fallbackIcon = icon
                }
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
                        .padding(.leading)
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
