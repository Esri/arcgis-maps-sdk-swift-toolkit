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
import OSLog
import SwiftUI

/// A view that display a `Popup` and its evaluated elements.
///
/// This is used by the `PopupView` to display its initial popup and the
/// following ones resulting from navigating through utility associations.
struct EmbeddedPopupView: View {
    /// The `Popup` to display.
    let popup: Popup
    
    /// The result of evaluating the popup expressions.
    @State private var evaluationResult: Result<[PopupElement], Error>?
    
    var body: some View {
        VStack(spacing: 0) {
            switch evaluationResult {
            case .success(let evaluatedElements):
                PopupElementList(
                    popupElements: evaluatedElements,
                    editSummary: popup.editSummary
                )
                .environment(\.popupTitle, popup.title)
            case .failure(let error):
                Text(
                    "Popup evaluation failed: \(error.localizedDescription)",
                    bundle: .toolkitModule,
                    comment: """
                             An error message shown when a popup cannot be displayed.
                             The variable provides additional data.
                             """
                )
            case nil:
                HStack(alignment: .center, spacing: 10) {
                    Text(
                        "Evaluating popup expressions",
                        bundle: .toolkitModule,
                        comment: "A label indicating popup expressions are being evaluated."
                    )
                    ProgressView()
                }
            }
        }
#if targetEnvironment(macCatalyst)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
#endif
        .preference(key: PresentedPopupPreferenceKey.self, value: .init(object: popup))
        .popupViewToolbar()
        .navigationTitle(popup.title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: ObjectIdentifier(popup)) {
            // Initial evaluation for a newly assigned popup.
            guard !Task.isCancelled else { return }
            
            evaluationResult = nil
            await evaluateExpressions()
        }
        .task(id: ObjectIdentifier(popup)) {
            // If the popup is showing for a dynamic entity, then observe
            // the changes and update the popup accordingly.
            guard let dynamicEntity = popup.geoElement as? DynamicEntity else { return }
            for await changes in dynamicEntity.changes {
                if changes.dynamicEntityWasPurged || Task.isCancelled {
                    break
                }
                if changes.receivedObservation != nil {
                    await evaluateExpressions()
                }
            }
        }
    }
    
    /// Evaluates the arcade expressions and updates the evaluation result property.
    private func evaluateExpressions() async {
        evaluationResult = await Result {
            _ = try await popup.evaluateExpressions()
            return popup.evaluatedElements
        }
    }
}

extension EmbeddedPopupView {
    private struct PopupElementList: View {
        let popupElements: [PopupElement]
        let editSummary: String
        
        var body: some View {
            List {
                ForEach(popupElements) { popupElement in
                    Group {
                        switch popupElement {
                        case let popupElement as AttachmentsPopupElement:
                            AttachmentsFeatureElementView(popupElement: popupElement)
                        case let popupElement as FieldsPopupElement:
                            FieldsPopupElementView(popupElement: popupElement)
                        case let popupElement as MediaPopupElement:
                            MediaPopupElementView(popupElement: popupElement)
                        case let popupElement as TextPopupElement:
                            TextPopupElementView(popupElement: popupElement)
                        case let popupElement as UtilityAssociationsPopupElement:
                            UtilityAssociationsPopupElementView(popupElement: popupElement)
                        default:
                            EmptyView()
                        }
                    }
                    .popupListRowStyle()
                }
                
                if !editSummary.isEmpty {
                    Text(editSummary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .listSectionSeparator(.hidden, edges: .top)
                }
            }
            .listStyle(.plain)
        }
    }
}

extension EnvironmentValues {
    /// The title of the popup associated with the view.
    @Entry var popupTitle = ""
}

extension View {
    /// Adds the list row style for the PopupView.
    func popupListRowStyle() -> some View {
        self.listSectionSeparator(.hidden, edges: .top)
#if targetEnvironment(macCatalyst)
            .listRowInsets(.init(top: 8, leading: 19, bottom: 8, trailing: 19))
#endif
    }
}
