// Copyright 2023 Esri
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
import ArcGISToolkit
import SwiftUI

struct FeatureFormExampleView: View {
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// A Boolean value indicating whether the alert confirming the user's intent to cancel is displayed.
    @State private var isCancelConfirmationPresented = false
    
    /// The validation error visibility configuration of the form.
    @State var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var model = Model()
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    if model.isFormPresented {
                        isCancelConfirmationPresented = true
                    } else {
                        identifyScreenPoint = screenPoint
                    }
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition,
                       let featureForm = FeatureForm(feature: feature, definition: formDefinition) {
                        model.featureForm = featureForm
                    }
                }
                .ignoresSafeArea(.keyboard)
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .leading,
                    isPresented: $model.isFormPresented
                ) {
                    if let featureForm = model.featureForm {
                        FeatureFormView(featureForm: featureForm)
                            .validationErrors(validationErrorVisibility)
                            .padding([.horizontal])
                    }
                }
                .onChange(of: model.isFormPresented) { isFormPresented in
                    if !isFormPresented { validationErrorVisibility = .automatic }
                }
                .alert("Discard edits", isPresented: $isCancelConfirmationPresented) {
                        Button("Discard edits", role: .destructive) {
                            model.discardEdits()
                        }
                        Button("Continue editing", role: .cancel) { }
                } message: {
                    Text("Updates to this feature will be lost.")
                }
                .navigationBarBackButtonHidden(model.isFormPresented)
                .toolbar {
                    // Once iOS 16.0 is the minimum supported, the two conditionals to show the
                    // buttons can be merged and hoisted up as the root content of the toolbar.
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        if model.isFormPresented {
                            Button("Cancel", role: .cancel) {
                                isCancelConfirmationPresented = true
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if model.isFormPresented {
                            Button("Submit") {
                                validationErrorVisibility = .visible
                                Task {
                                    await model.submitChanges()
                                }
                            }
                        }
                    }
                }
        }
    }
}

extension FeatureFormExampleView {
    /// Identifies features, if any, at the current screen point.
    /// - Parameter proxy: The proxy to use for identification.
    /// - Returns: The first identified feature in a layer with
    /// a feature form definition.
    func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
        guard let identifyScreenPoint else { return nil }
        let identifyResult = try? await proxy.identifyLayers(
            screenPoint: identifyScreenPoint,
            tolerance: 10
        )
            .first(where: { result in
                if let feature = result.geoElements.first as? ArcGISFeature,
                   (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
                    return true
                } else {
                    return false
                }
            })
        return identifyResult?.geoElements.first as? ArcGISFeature
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: "<#URL#>")!
    }
}

/// The model class for the form example view
@MainActor
class Model: ObservableObject {
    /// The feature form.
    @Published var featureForm: FeatureForm? {
        didSet {
            isFormPresented = featureForm != nil
        }
    }
    
    /// A Boolean value indicating whether or not the form is displayed.
    @Published var isFormPresented = false
    
    /// Reverts any local edits that haven't yet been saved to service geodatabase.
    func discardEdits() {
        featureForm?.discardEdits()
        featureForm = nil
    }
    
    /// Submit the changes made to the form.
    func submitChanges() async {
        guard let featureForm = featureForm,
              let table = featureForm.feature.table as? ServiceFeatureTable,
              table.isEditable,
              let database = table.serviceGeodatabase else {
            print("A precondition to submit the changes wasn't met.")
            return
        }
        
        guard featureForm.validationErrors.isEmpty else { return }
        
        try? await table.update(featureForm.feature)
        
        guard database.hasLocalEdits else {
            print("No submittable changes found.")
            return
        }
        
        let results = try? await database.applyEdits()
        
        if results?.first?.editResults.first?.didCompleteWithErrors ?? false {
            print("An error occurred while submitting the changes.")
        }
        
        self.featureForm = nil
    }
}
