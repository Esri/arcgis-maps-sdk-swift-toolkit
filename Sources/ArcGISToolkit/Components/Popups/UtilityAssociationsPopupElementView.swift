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
    
    /// The model for fetching the popup element's associations filter results.
    @State private var associationsFilterResultsModel: AssociationsFilterResultsModel
    
    /// A Boolean value indicating whether the disclosure group is expanded.
    @State private var isExpanded = true
    
    /// A Boolean value indicating whether the progress view is showing.
    @State private var progressViewIsShowing = true
    
    init(popupElement: UtilityAssociationsPopupElement) {
        self.popupElement = popupElement
        self._associationsFilterResultsModel = .init(wrappedValue: .init(popupElement: popupElement))
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            switch associationsFilterResultsModel.result {
            case .success(let associationsFilterResults):
                if associationsFilterResults.isEmpty {
                    Text(
                        "No Associations",
                        bundle: .toolkitModule,
                        comment: "A label indicating that no associations are available for the popup element."
                    )
                } else {
                    ForEach(associationsFilterResults, id: \.id) {
                        UtilityAssociationsFilterResultLink(filterResult: $0)
                    }
                    .environment(\.associationDisplayCount, popupElement.displayCount)
                }
            case .failure(let error):
                Text(
                    "Error fetching filter results: \(error.localizedDescription)",
                    bundle: .toolkitModule,
                    comment: """
                             An error message shown when the element's
                             associations filter results cannot be displayed.
                             The variable provides additional data.
                             """
                )
            case nil:
                VStack {
                    // This check and the enclosing stack/modifiers workaround an issue where the
                    // ProgressView doesn't reappear after scrolling away from it in the list.
                    if progressViewIsShowing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .accessibilityIdentifier("Fetching filter results")
                    }
                }
                .onAppear {
                    progressViewIsShowing = true
                }
                .onDisappear {
                    progressViewIsShowing = false
                }
            }
        } label: {
            PopupElementHeader(
                title: popupElement.displayTitle,
                description: popupElement.description
            )
            .catalystPadding(4)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("Associations Popup Element")
        }
        .disclosureGroupPadding()
    }
}

/// A view model for fetching associations filter results.
@Observable
private final class AssociationsFilterResultsModel {
    /// The result of fetching the associations filter results.
    private(set) var result: Result<[UtilityAssociationsFilterResult], Error>?
    
    /// The task for fetching the associations filter results.
    @ObservationIgnored private var task: Task<Void, Never>?
    
    /// Fetches the associations filter results from a given popup element.
    /// - Parameter popupElement: The popup element containing the associations filter results.
    @MainActor
    init(popupElement: UtilityAssociationsPopupElement) {
        task = Task { [weak self] in
            guard !Task.isCancelled, let self else {
                return
            }
            
            let result = await Result {
                try await popupElement.associationsFilterResults.filter { $0.resultCount > 0 }
            }
            withAnimation {
                self.result = result
            }
        }
    }
    
    deinit {
        task?.cancel()
    }
}

/// A view that displays a `UtilityAssociationsFilterResult` and allows
/// navigating to its group results.
private struct UtilityAssociationsFilterResultLink: View {
    /// The title of the popup the filter result was derived from.
    @Environment(\.popupTitle) private var popupTitle
    
    /// The association display count of the popup element the filter result was derived from.
    @Environment(\.associationDisplayCount) private var associationDisplayCount
    
    /// The utility associations filter result to display.
    let filterResult: UtilityAssociationsFilterResult
    
    var body: some View {
        NavigationLink {
            List(filterResult.groupResults, id: \.id) { groupResult in
                UtilityAssociationGroupResultView(groupResult: groupResult)
#if targetEnvironment(macCatalyst)
                    .listRowInsets(.toolkitDefault)
#endif
            }
            .listStyle(.plain)
            .navigationTitle(filterResult.filter.displayTitle, subtitle: popupTitle)
            .navigationBarTitleDisplayMode(.inline)
            .popupViewToolbar()
            .environment(\.popupTitle, popupTitle)
            .environment(\.associationDisplayCount, associationDisplayCount)
        } label: {
            LabeledContent {
                Text(filterResult.resultCount, format: .number)
            } label: {
                Text(filterResult.filter.displayTitle)
                if !filterResult.filter.description.isEmpty {
                    Text(filterResult.filter.description)
                        .font(.caption)
                }
            }
            .lineLimit(1)
        }
        .accessibilityIdentifier("Associations Filter Result")
    }
}

/// A view that displays a `UtilityAssociationGroupResult` and allows
/// navigating through its association results.
private struct UtilityAssociationGroupResultView: View {
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
                NavigationLink {
                    EmbeddedPopupView(popup: result.associatedFeature.toPopup())
                } label: {
                    UtilityAssociationResultLabel(result: result)
                }
            }
            
            if groupResult.associationResults.count > associationDisplayCount {
                NavigationLink {
                    SearchUtilityAssociationResultsView(results: groupResult.associationResults)
                        .navigationTitle(groupResult.name, subtitle: popupTitle)
                        .navigationBarTitleDisplayMode(.inline)
                        .popupViewToolbar()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(
                                "Show all",
                                bundle: .toolkitModule,
                                comment: "A label for a button to show all the association results."
                            )
                            Text(
                                "Total: \(groupResult.associationResults.count)",
                                bundle: .toolkitModule,
                                comment: "Text indicating the total count of association results."
                            )
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
            .accessibilityIdentifier("Association Group Result")
        }
        .disclosureGroupPadding()
    }
}

/// A view for searching through a list of utility association results.
private struct SearchUtilityAssociationResultsView: View {
    /// The utility association results to search through.
    let results: [UtilityAssociationResult]
    
    /// The text in the search bar.
    @State private var text = ""
    
    /// The results filtered by the search text.
    private var filteredResults: [UtilityAssociationResult] {
        text.isEmpty ? results : results.filter { $0.title.localizedStandardContains(text) }
    }
    
    var body: some View {
        List(filteredResults, id: \.associatedFeature.globalID) { result in
            NavigationLink {
                EmbeddedPopupView(popup: result.associatedFeature.toPopup())
            } label: {
                UtilityAssociationResultLabel(result: result)
            }
#if targetEnvironment(macCatalyst)
            .listRowInsets(.toolkitDefault)
#endif
        }
        .listStyle(.plain)
        .searchable(
            text: $text,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: titleText
        )
    }
    
    private var titleText: Text {
        .init(
            "Title",
            bundle: .toolkitModule,
            comment: "A label for a text entry field that allows the user to filter a list of association results by title."
        )
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
    /// The ID of the utility associations filter result object.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

private extension UtilityAssociationGroupResult {
    /// The ID of the utility associations group result object.
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
