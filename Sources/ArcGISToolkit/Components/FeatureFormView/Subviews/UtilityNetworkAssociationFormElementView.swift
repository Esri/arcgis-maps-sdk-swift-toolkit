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
    let associationKindGroups: [FeatureFormView.AssociationKindGroup]
    
    /// <#Description#>
    let selectionAction: ((FeatureFormView.AssociationKindGroup) -> Void)
    
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
                        selectionAction(group)
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
                    .buttonStyle(.plain)
                }
            )
        }
    }
}

extension FeatureFormView {
    struct Association: Identifiable {
        let feature: ArcGISFeature
        
        /// <#Description#>
        let description: String?
        
        /// <#Description#>
        let fractionAlongEdge: Double?
        
        /// <#Description#>
        public let id = UUID()
        
        /// <#Description#>
        let name: String
        
        /// <#Description#>
        let terminalName: String?
    }
    
    public struct AssociationView: View {
        /// The view model for the form.
        @EnvironmentObject var model: FormViewModel
        
        var association: Association
        
        /// <#Description#>
        let selectionAction: ((ArcGISFeature) -> Void)
        
        public var body: some View {
            Button {
                selectionAction(association.feature)
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
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(5)
                    .font(.caption2)
                }
            }
            .buttonStyle(.plain)
            .padding(.leading)
        }
    }
    
    public struct AssociationKindGroup: Equatable, Hashable, Identifiable {
        /// <#Description#>
        let networkSourceGroups: [NetworkSourceGroup]
        
        /// <#Description#>
        public let id = UUID()
        
        /// <#Description#>
        let name: String
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
            && lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
    }
    
    public struct AssociationKindGroupView: View {
        let associationKindGroup: AssociationKindGroup
        
        let selectionAction: ((NetworkSourceGroup) -> Void)
        
        public init(associationKindGroup: AssociationKindGroup, selectionAction: @escaping (NetworkSourceGroup) -> Void) {
            self.associationKindGroup = associationKindGroup
            self.selectionAction = selectionAction
        }
        
        public var body: some View {
            List(associationKindGroup.networkSourceGroups) { group in
                Button {
                    selectionAction(group)
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
    
    public struct NetworkSourceGroup: Equatable, Hashable, Identifiable {
        /// <#Description#>
        let associations: [Association]
        
        /// <#Description#>
        public let id = UUID()
        
        /// <#Description#>
        let name: String
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.name == rhs.name
            && lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
    }
    
    public struct NetworkSourceGroupView: View {
        let networkSourceGroup:  NetworkSourceGroup
        
        let selectionAction: (ArcGISFeature) -> Void
        
        public init(networkSourceGroup: NetworkSourceGroup, selectionAction: @escaping (ArcGISFeature) -> Void) {
            self.networkSourceGroup = networkSourceGroup
            self.selectionAction = selectionAction
        }
        
        public var body: some View {
            List(networkSourceGroup.associations) {
                AssociationView(association: $0, selectionAction: selectionAction)
                    .listRowBackground(Color(uiColor: .tertiarySystemFill))
            }
            .scrollContentBackground(.hidden)
        }
    }
}
