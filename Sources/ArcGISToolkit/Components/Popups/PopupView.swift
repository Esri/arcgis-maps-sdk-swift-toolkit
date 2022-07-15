// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// A view displaying the elements of a single Popup.
public struct PopupView: View {
    /// Creates a `PopupView` with the given popup.
    /// - Parameter popup: The popup to display.
    public init(popup: Popup) {
        self.popup = popup
    }
    
    /// The `Popup` to display.
    private var popup: Popup
    
    /// A Boolean value indicating whether the popup's elements have been evaluated via
    /// the `popup.evaluateExpressions()` method.
    @State private var isPopupEvaluated: Bool? = nil
    
    /// The results of calling the `popup.evaluateExpressions()` method.
    @State private var expressionEvaluations: [PopupExpressionEvaluation]? = nil
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(popup.title)
                .fontWeight(.bold)
            Divider()
            Group {
                if isPopupEvaluated == nil {
                    VStack(alignment: .center) {
                        Text("Evaluating popoup expressions...")
                        ProgressView()
                    }
                } else if isPopupEvaluated! {
                    popupElementScrollView(popup: popup)
                } else {
                    Text("Popup failed evaluation.")
                }
            }
        }
        .task {
            do {
                expressionEvaluations = try await popup.evaluateExpressions()
                isPopupEvaluated = true
            } catch {
                isPopupEvaluated = false
            }
        }
    }
    
    struct popupElementScrollView: View {
        var popup: Popup
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(popup.evaluatedElements) { popupElement in
                        switch popupElement {
                        case let popupElement as AttachmentsPopupElement:
                            Text("AttachmentsPopupElementView implementation coming soon.")
                        case let popupElement as FieldsPopupElement:
                            FieldsPopupElementView(popupElement: popupElement)
                        case let popupElement as MediaPopupElement:
                            Text("MediaPopupElementView implementation coming soon.")
                        case let popupElement as TextPopupElement:
                            Text("TextPopupElementView implementation coming soon.")
                        default:
                            EmptyView()
                        }
                        
                        Divider()
                    }
                }
            }
        }
    }
}

extension PopupElement: Identifiable {}
