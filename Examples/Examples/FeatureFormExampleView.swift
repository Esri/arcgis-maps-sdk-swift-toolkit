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
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// A Boolean value indicating whether the alert confirming the user's intent to cancel is presented.
    @State private var cancelConfirmationIsPresented = false
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The validation error visibility configuration of the form.
    @State private var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var model = Model()
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    if model.isFormPresented {
                        cancelConfirmationIsPresented = true
                    } else {
                        identifyScreenPoint = screenPoint
                    }
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
                        model.featureForm = FeatureForm(feature: feature, definition: formDefinition)
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
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }
                }
                .onChange(of: model.isFormPresented) { isFormPresented in
                    if !isFormPresented { validationErrorVisibility = .automatic }
                }
                .alert("Discard edits", isPresented: $cancelConfirmationIsPresented) {
                    Button("Discard edits", role: .destructive) {
                        model.discardEdits()
                    }
                    Button("Continue editing", role: .cancel) { }
                } message: {
                    Text("Updates to this feature will be lost.")
                }
                .alert(
                    "The form wasn't submitted",
                    isPresented: Binding(
                        get: { model.submissionError != nil },
                        set: { _ in model.submissionError = nil }
                    )
                ) { } message: {
                    if let submissionError = model.submissionError {
                        submissionError
                    }
                }
                .navigationBarBackButtonHidden(model.isFormPresented)
                .toolbar {
                    if model.isFormPresented {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel", role: .cancel) {
                                cancelConfirmationIsPresented = true
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
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
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}

/// The model class for the form example view
@MainActor
class Model: ObservableObject {
    /// The feature form.
    @Published var featureForm: FeatureForm? {
        willSet {
            if let featureForm = newValue {
                featureForm.featureLayer?.selectFeature(featureForm.feature)
            } else if let featureForm = self.featureForm {
                featureForm.featureLayer?.unselectFeature(featureForm.feature)
            }
        }
        didSet {
            isFormPresented = featureForm != nil
        }
    }
    
    /// A Boolean value indicating whether or not the form is displayed.
    @Published var isFormPresented = false
    
    /// A description of the error that prevented the form from being submitted.
    @Published var submissionError: Text?
    
    /// Reverts any local edits that haven't yet been saved to service geodatabase.
    func discardEdits() {
        featureForm?.discardEdits()
        featureForm = nil
    }
    
    /// Submit the changes made to the form.
    func submitChanges() async {
        guard let featureForm,
              let table = featureForm.feature.table as? ServiceFeatureTable,
              let database = table.serviceGeodatabase else {
            print("A precondition to submit the changes wasn't met.")
            return
        }
        
        guard table.isEditable else {
            submissionError = Text("The feature table isn't editable.")
            return
        }
        
        guard featureForm.validationErrors.isEmpty else {
            submissionError = Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true).")
            return
        }
        
        try? await table.update(featureForm.feature)
        
        guard database.hasLocalEdits else {
            print("No submittable changes found.")
            return
        }
        
        do {
            if let serviceInfo = database.serviceInfo,
               serviceInfo.canUseServiceGeodatabaseApplyEdits {
                _ = try await database.applyEdits()
            } else {
                _ = try await table.applyEdits()
            }
        } catch {
            submissionError = Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)")
        }
        
        self.featureForm = nil
    }
}

private extension FeatureForm {
    /// The layer to which the feature belongs.
    var featureLayer: FeatureLayer? {
        feature.table?.layer as? FeatureLayer
    }
}
