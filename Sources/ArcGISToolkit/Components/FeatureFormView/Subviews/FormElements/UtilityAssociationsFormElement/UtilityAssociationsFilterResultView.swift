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

extension FeatureFormView {
    /// A view for a utility associations filter result.
    struct UtilityAssociationsFilterResultView: View {
        /// The model containing the latest association filter results.
        let associationsFilterResultsModel: AssociationsFilterResultsModel
        /// The form element containing the filter result.
        let element: UtilityAssociationsFormElement
        /// The view model for the form.
        let embeddedFeatureFormViewModel: EmbeddedFeatureFormViewModel
        /// The title of the selected utility associations filter result.
        let filterTitle: String
        
        /// The selected utility associations filter result.
        var filterResult: UtilityAssociationsFilterResult? {
            try? associationsFilterResultsModel.result?
                .get()
            .first(where: { $0.filter.title == filterTitle} )
        }
        /// The set of group results within the filter result.
        var groupResults: [UtilityAssociationGroupResult] {
            filterResult?.groupResults ?? []
        }
        
        /// The navigation path for the navigation stack presenting this view.
        @Environment(\.navigationPath) var navigationPath
        
        /// A Boolean value indicating whether the element is editable.
        @State private var isEditable = false
        
        var body: some View {
            VStack {
                List {
                    Section {
                        // TODO: Improve group identification (Apollo 1391).
                        ForEach(groupResults, id: \.name) { utilityAssociationGroupResult in
                            Button {
                                navigationPath?.wrappedValue.append(
                                    FeatureFormView.NavigationPathItem.utilityAssociationGroupResultView(
                                        embeddedFeatureFormViewModel,
                                        associationsFilterResultsModel,
                                        element,
                                        filterTitle,
                                        utilityAssociationGroupResult.name
                                    )
                                )
                            } label: {
                                HStack {
                                    Text(utilityAssociationGroupResult.name)
                                    Spacer()
                                    Group {
                                        Text(utilityAssociationGroupResult.associationResults.count, format: .number)
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            .tint(.primary)
                        }
                    } footer: {
                        addAssociationMenu
                    }
                    .onChange(of: embeddedFeatureFormViewModel.hasEdits) {
                        associationsFilterResultsModel.fetchResults()
                    }
                }
            }
        }
        
        var addAssociationMenu: some View {
            Menu(
                "Add Association",
                systemImage: "plus.circle.fill"
            ) {
                Button {
                    navigationPath?.wrappedValue.append(
                        FeatureFormView.NavigationPathItem.utilityAssociationNetworkSourcesView(
                            embeddedFeatureFormViewModel,
                            element,
                            filterResult!.filter
                        )
                    )
                } label: {
                    #warning("Comment needed")
                    Text(
                        "From Network Data Source",
                        bundle: .toolkitModule,
                        comment: ""
                    )
                }
                Button {} label: {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text.selectFeatureOnMap
                            Text.tapSelectAreaOrDrawPolygon
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .tint(.primary)
                    }
                }
                .disabled(true)
            }
            .disabled(!isEditable)
            .onIsEditableChange(of: element) { newIsEditable in
                isEditable = newIsEditable
            }
        }
    }
}

private extension Text {
    static var addAssociation: Self {
        .init(
            "Add Association",
            bundle: .toolkitModule,
            comment: "A label for a button to add a new utility network association."
        )
    }
    
    static var selectFeatureOnMap: Self {
        .init(
            "On Map",
            bundle: .toolkitModule,
            comment: """
                     A label indicating features can be selected by 
                     interactively tapping on the map.
                     """
        )
    }
    
    #warning("Comment needed")
    static var tapSelectAreaOrDrawPolygon: Self {
        .init(
            "Tap, select area, or draw polygon",
            bundle: .toolkitModule,
            comment: ""
        )
    }
}
