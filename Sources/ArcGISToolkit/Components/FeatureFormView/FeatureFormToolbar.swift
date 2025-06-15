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

extension View {
    func featureFormToolbar(_ featureForm: FeatureForm) -> some View {
        self.modifier(FeatureFormToolbar(featureForm: featureForm))
    }
}

struct FeatureFormToolbar: ViewModifier {
    @Environment(\.closeButtonVisibility) var closeButtonVisibility
    
    @Environment(\.editingButtonVisibility) var editingButtonsVisibility
    
    @Environment(\.finishEditingError) var finishEditingError
    
    @Environment(\.onFormEditingEventAction) var onFormEditingEventAction
    
    @Environment(\.presentedForm) var presentedForm
    
    @Environment(\.setAlertContinuation) var setAlertContinuation
    
    @Environment(\._validationErrorVisibility) var _validationErrorVisibility
    
    @State private var hasEdits: Bool = false
    
    let featureForm: FeatureForm
    
    func body(content: Content) -> some View {
        content
            .task(id: featureForm.feature.globalID) {
                for await hasEdits in featureForm.$hasEdits {
                    withAnimation { self.hasEdits = hasEdits }
                }
            }
            .toolbar {
                if closeButtonVisibility != .hidden {
                    ToolbarItem(placement: .topBarTrailing) {
                        XButton(.dismiss) {
                            if hasEdits {
                                setAlertContinuation?(false) {
                                    presentedForm?.wrappedValue = nil
                                }
                            } else {
                                presentedForm?.wrappedValue = nil
                            }
                        }
                        .font(.title)
                    }
                }
                if hasEdits, editingButtonsVisibility != .hidden {
                    ToolbarItem(placement: .bottomBar) {
                        FormFooter(
                            featureForm: featureForm,
                            formHandlingEventAction: onFormEditingEventAction,
                            validationErrorVisibility: _validationErrorVisibility,
                            finishEditingError: finishEditingError
                        )
                    }
                }
            }
    }
}
