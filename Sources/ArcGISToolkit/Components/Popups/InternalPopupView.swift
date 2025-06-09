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

/// A view that display a `Popup` and its evaluated elements.
struct InternalPopupView: View {
    /// The `Popup` to display.
    let popup: Popup
    
    /// The result of evaluating the popup expressions.
    @State private var evaluation: Evaluation?
    
    var body: some View {
        VStack(spacing: 0) {
            if let evaluation {
                if let error = evaluation.error {
                    Text(
                        "Popup evaluation failed: \(error.localizedDescription)",
                        bundle: .toolkitModule,
                        comment: """
                                 An error message shown when a popup cannot be displayed. The
                                 variable provides additional data.
                                 """
                    )
                } else {
                    PopupElementList(popupElements: evaluation.elements)
                        .environment(\.popupTitle, popup.title)
                }
            } else {
                HStack(alignment: .center, spacing: 10) {
                    Text(
                        "Evaluating popup expressions",
                        bundle: .toolkitModule,
                        comment: "A label indicating popup expressions are being evaluated."
                    )
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationLayerTitle(popup.title)
        .task(id: ObjectIdentifier(popup)) {
            // Initial evaluation for a newly assigned popup.
            guard !Task.isCancelled else { return }
            
            evaluation = nil
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
    
    /// Evaluates the arcade expressions and updates the evaluation property.
    private func evaluateExpressions() async {
        do {
            _ = try await popup.evaluateExpressions()
            evaluation = Evaluation(elements: popup.evaluatedElements)
        } catch {
            evaluation = Evaluation(error: error)
        }
    }
}

extension InternalPopupView {
    private struct PopupElementList: View {
        let popupElements: [PopupElement]
        
        var body: some View {
            List(popupElements) { popupElement in
                Group {
                    switch popupElement {
                    case let popupElement as AttachmentsPopupElement:
                        AttachmentsFeatureElementView(featureElement: popupElement)
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
#if targetEnvironment(macCatalyst)
                .listRowInsets(.toolkitDefault)
#endif
            }
            .listStyle(.plain)
            .phoneBottomPadding()
        }
    }
    
    /// An object used to hold the result of evaluating the expressions of a popup.
    private final class Evaluation {
        /// The evaluated elements.
        let elements: [PopupElement]
        /// The error that occurred during evaluation, if any.
        let error: Error?
        
        /// Creates an evaluation.
        /// - Parameters:
        ///   - elements: The evaluated elements.
        ///   - error: The error that occurred during evaluation, if any.
        init(elements: [PopupElement] = [], error: Error? = nil) {
            self.elements = elements
            self.error = error
        }
    }
}

extension EnvironmentValues {
    /// The title of the popup associated with the view.
    @Entry var popupTitle = ""
}
