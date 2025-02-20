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
    
    @Environment(\.navigationChangeRequestedAction) var navigationChangeRequestedAction: ((() -> Void) -> Void)?
    
    @Binding var navigationPath: NavigationPath
    
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
                        navigationChangeRequestedAction?({
                            navigationPath.append(group)
                        })
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
        enum Connection {
            case left
            case middle
            case right
        }
        
        /// <#Description#>
        let connectionPoint: Connection?
        
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let fractionAlongEdge: Double?
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let linkDestination: (any Hashable)?
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let terminalName: String?
    }
    
    struct AssociationView: View {
        var association: Association
        
        @State private var selectionTask: Task<Void, Never>?
        
        var body: some View {
            NavigationLink(value: association.linkDestination!) {
                HStack {
                    
                    if let connection = association.connectionPoint {
                        let image: String = switch connection {
                        case .left:
                            "connection-end-left"
                        case .middle:
                            "connection-middle"
                        case .right:
                            "connection-end-right"
                        }
                        Image(image, bundle: .toolkitModule)
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
                    Group {
                        if let percent = association.fractionAlongEdge {
                            Text(percent.formatted(.percent))
                        } else if let terminal = association.terminalName {
                            Text("Terminal: \(terminal)")
                        }
                    }
                    .padding(2.5)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(5)
                    .font(.caption2)
                }
            }
            .buttonStyle(.plain)
            .padding(.leading)
        }
    }
    
    struct AssociationKindGroup: Equatable, Hashable, Identifiable {
        /// <#Description#>
        let networkSourceGroups: [NetworkSourceGroup]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let presentingForm: String
        
        static func == (lhs: UtilityNetworkAssociationFormElementView.AssociationKindGroup, rhs: UtilityNetworkAssociationFormElementView.AssociationKindGroup) -> Bool {
            lhs.name == rhs.name
            && lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
    }
    
    struct AssociationKindGroupView: View {
        let associationKindGroup: AssociationKindGroup
        
        var body: some View {
            List(associationKindGroup.networkSourceGroups) { group in
                NavigationLink(value: group) {
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
    
    struct NetworkSourceGroup: Equatable, Hashable, Identifiable {
        /// <#Description#>
        let associations: [Association]
        
        /// <#Description#>
        let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let presentingForm: String
        
        static func == (lhs: UtilityNetworkAssociationFormElementView.NetworkSourceGroup, rhs: UtilityNetworkAssociationFormElementView.NetworkSourceGroup) -> Bool {
            lhs.name == rhs.name
            && lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
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
