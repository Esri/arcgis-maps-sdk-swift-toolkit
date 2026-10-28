// Copyright 2026 Esri
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

/// An inspector that presents a template picker and feature form for adding a
/// feature.
struct FeatureAddingInspector: View {
    /// The model that manages the feature-adding workflow.
    let model: FeatureAddingModel
    
    /// The navigation path through the template picker.
    var templatePickerNavigationPath: Binding<[LayerTemplate]> {
        .init {
            model.selectedLayerTemplate.map { [$0] } ?? []
        } set: { newLayerTemplates in
            model.selectedLayerTemplate = newLayerTemplates.first
        }
    }
    
    /// A Boolean value indicating whether the feature form view is presented.
    var featureFormViewIsPresented: Binding<Bool> {
        .init {
            model.featureForm != nil
        } set: { newValue in
            guard !newValue else { return }
            model.stop()
        }
    }
    
    var body: some View {
        Group {
            if let featureForm = model.featureForm {
                FeatureFormView(root: featureForm, isPresented: featureFormViewIsPresented)
                    .onDisappear { model.stop() }
            } else {
                NavigationStack(path: templatePickerNavigationPath) {
                    FeatureEditorTemplatePicker(model: model)
                }
            }
        }
        .animation(.default, value: model.featureForm?.id)
    }
}
