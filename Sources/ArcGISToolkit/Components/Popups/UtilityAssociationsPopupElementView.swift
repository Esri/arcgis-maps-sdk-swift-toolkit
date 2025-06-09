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

/// A view that displays a `UtilityAssociationsPopupElement` and allows
/// navigating through its filter results.
struct UtilityAssociationsPopupElementView: View {
    /// The popup element to display.
    let popupElement: UtilityAssociationsPopupElement
    
    /// The popup element's associations filter results.
    @State private var filterResults: [UtilityAssociationsFilterResult] = []
    
    /// A Boolean value indicating whether the disclosure group is expanded.
    @State private var isExpanded = true
    
    /// A Boolean value indicating whether the associations filter results are being loaded.
    @State private var isLoading = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .task {
                        let filterResults = try? await popupElement.associationsFilterResults
                        self.filterResults = filterResults?.filter { $0.resultCount > 0 } ?? []
                        
                        isLoading = false
                    }
            } else if filterResults.isEmpty {
                Label {
                    Text("No Associations")
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.gray)
                }
            } else {
                ForEach(filterResults, id: \.id) {
                    UtilityAssociationsFilterResultLink(filterResult: $0)
                }
                .environment(\.associationDisplayCount, popupElement.displayCount)
            }
        } label: {
            PopupElementHeader(
                title: popupElement.displayTitle,
                description: popupElement.description
            )
            .catalystPadding(4)
        }
        .disclosureGroupPadding()
    }
}

/// A view that displays a `UtilityAssociationsFilterResult` and allows
/// navigating to its group results.
private struct UtilityAssociationsFilterResultLink: View {
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The title of the popup the filter result was derived from.
    @Environment(\.popupTitle) private var popupTitle
    
    /// The association display count of the popup element the filter result was derived from.
    @Environment(\.associationDisplayCount) private var associationDisplayCount
    
    /// The utility associations filter result to display.
    let filterResult: UtilityAssociationsFilterResult
    
    var body: some View {
        Button {
            navigationLayerModel.push {
                List(filterResult.groupResults, id: \.name) { groupResult in
                    UtilityAssociationGroupResultView(groupResult: groupResult)
#if targetEnvironment(macCatalyst)
                        .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
#endif
                }
                .listStyle(.inset)
                .phoneBottomPadding()
                .navigationLayerTitle(filterResult.filter.displayTitle, subtitle: popupTitle)
                .environment(\.popupTitle, popupTitle)
                .environment(\.associationDisplayCount, associationDisplayCount)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(filterResult.filter.displayTitle)
                    if !filterResult.filter.description.isEmpty {
                        Text(filterResult.filter.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
                Spacer()
                Group {
                    Text(filterResult.resultCount, format: .number)
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.secondary)
            }
#if os(iOS)
            // Make the entire row tappable.
            .contentShape(.rect)
#endif
        }
    }
}

/// A view that displays a `UtilityAssociationGroupResult` and allows
/// navigating through its association results.
private struct UtilityAssociationGroupResultView: View {
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The title of the popup the group result was derived from.
    @Environment(\.popupTitle) private var popupTitle
    
    /// The association display count of the popup element the group result was derived from.
    @Environment(\.associationDisplayCount) private var associationDisplayCount
    
    /// The utility association group result to display.
    let groupResult: UtilityAssociationGroupResult
    
    /// A Boolean value indicating whether the disclosure group is expanded.
    @State private var isExpanded = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            let associationResults = groupResult.associationResults.prefix(associationDisplayCount)
            ForEach(associationResults, id: \.associatedFeature.globalID) { result in
                UtilityAssociationResultButton(result.displayTitle, result: result) {
                    navigationLayerModel.push {
                        InternalPopupView(popup: result.associatedFeature.toPopup())
                    }
                }
            }
            
            if groupResult.associationResults.count > associationDisplayCount {
                Button {
                    navigationLayerModel.push {
                        SearchUtilityAssociationResultsView(results: groupResult.associationResults)
                            .navigationLayerTitle(groupResult.name, subtitle: popupTitle)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Show all")
                            Text("Total: \(groupResult.associationResults.count)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .lineLimit(1)
                        Spacer()
                        Image(systemName: "list.bullet")
                    }
                }
            }
        } label: {
            LabeledContent(groupResult.name) {
                Text(groupResult.associationResults.count, format: .number)
            }
            .catalystPadding(4)
        }
        .disclosureGroupPadding()
    }
}

/// A view for searching through a list of utility association results.
private struct SearchUtilityAssociationResultsView: View {
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The utility association results to search through.
    let results: [UtilityAssociationResult]
    
    /// The text in the search bar.
    @State private var text = ""
    
    /// The results filtered by the search text.
    private var filteredResults: [UtilityAssociationResult] {
        text.isEmpty ? results : results.filter { $0.displayTitle.contains(text) }
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $text, prompt: "Title")
                .padding(.horizontal)
            
            List(filteredResults, id: \.associatedFeature.globalID) { result in
                UtilityAssociationResultButton(result.displayTitle, result: result) {
                    navigationLayerModel.push {
                        InternalPopupView(popup: result.associatedFeature.toPopup())
                    }
                }
#if targetEnvironment(macCatalyst)
                .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
#endif
            }
            .listStyle(.inset)
            .phoneBottomPadding()
        }
    }
}

// MARK: - Extensions

private extension ArcGISFeature {
    /// Returns a popup created from the feature and the feature table's popup definition.
    func toPopup() -> Popup {
        let popupDefinition: PopupDefinition? =
        if let popupDefinition = table?.popupDefinition(for: self) {
            popupDefinition
        } else if let subtype, let featureTable = table as? ArcGISFeatureTable {
            featureTable.subtypeSubtables.first(where: { $0.name == subtype.name })?.popupDefinition
        } else {
            nil
        }
        
        return Popup(geoElement: self, definition: popupDefinition)
    }
}

private extension EnvironmentValues {
    /// The environment value to access the number of associations to display.
    @Entry var associationDisplayCount = 3
}

private extension UtilityAssociationsFilter {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? "\(kind)".capitalized : "\(title)"
    }
}

private extension UtilityAssociationsFilterResult {
    /// The ID of the utility associations filter result.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

private extension UtilityAssociationsPopupElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? String(
            localized: "Associations",
            bundle: .toolkitModule,
            comment: "A label in reference to utility associations elements contained within a popup."
        ) : title
    }
}

private extension UtilityAssociationResult {
    /// A title for the result.
    var displayTitle: String {
        let popup = associatedFeature.toPopup()
        return popup.title.isEmpty ? "Unknown" : popup.title
    }
}
