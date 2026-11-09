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

import ArcGIS
import SwiftUI

/// An inspector that presents a template picker and feature form for adding a
/// feature.
struct FeatureAddingInspector: View {
    /// The model that manages the feature-adding workflow.
    let model: FeatureAddingModel
    
    /// The features currently selected on their layers.
    @State private var selectedFeatures = [ArcGISFeature]()
    
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
            model.featureFormViewModel != nil
        } set: { newValue in
            guard !newValue else { return }
            model.stop()
        }
    }
    
    var body: some View {
        Group {
            if let featureFormViewModel = model.featureFormViewModel {
                FeatureFormView(
                    model: featureFormViewModel,
                    isPresented: featureFormViewIsPresented
                )
                .onChange(of: featureFormViewModel.selectedForm?.id, initial: true) {
                    updateSelectedFeatures(featureFormViewModel)
                }
                .onDisappear {
                    clearSelectedFeatures()
                    model.stop()
                }
            } else {
                NavigationStack(path: templatePickerNavigationPath) {
                    FeatureEditorTemplatePicker(model: model)
                }
            }
        }
        .animation(
            .default,
            value: model.featureFormViewModel?.forms.map(\.id)
        )
    }
    
    /// Selects the features shown by the active form or in the form picker.
    private func updateSelectedFeatures(_ formViewModel: FeatureFormView.Model) {
        clearSelectedFeatures()
        
        let features: [ArcGISFeature]
        if let selectedForm = formViewModel.selectedForm {
            features = [selectedForm.feature]
            model.showFeature(selectedForm.feature)
        } else {
            features = formViewModel.forms.map(\.feature)
            model.showFeatures(features)
        }
        
        var featuresByLayer: [ObjectIdentifier: (
            layer: any FeatureSelectableLayer,
            features: [Feature]
        )] = [:]
        var selectableFeatures = [ArcGISFeature]()
        for feature in features {
            guard let layer = feature.table?.layer as? FeatureSelectableLayer else { continue }
            let id = ObjectIdentifier(layer)
            if var selection = featuresByLayer[id] {
                selection.features.append(feature)
                featuresByLayer[id] = selection
            } else {
                featuresByLayer[id] = (layer, [feature])
            }
            selectableFeatures.append(feature)
        }
        
        for selection in featuresByLayer.values {
            selection.layer.selectFeatures(selection.features)
        }
        selectedFeatures = selectableFeatures
    }
    
    /// Clears the selected features from their layers.
    private func clearSelectedFeatures() {
        for feature in selectedFeatures {
            guard let layer = feature.table?.layer as? FeatureSelectableLayer else { continue }
            layer.unselectFeature(feature)
        }
        selectedFeatures.removeAll()
    }
}
