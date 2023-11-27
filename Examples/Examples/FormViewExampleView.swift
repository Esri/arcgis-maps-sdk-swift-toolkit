// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FormViewExampleView: View {
    /// A Boolean value indicating whether the alert confirming the user's intent to cancel is displayed.
    @State private var cancelConfirmationIsShowing = false
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// A Boolean value indicating whether or not the form is displayed.
    @State private var isPresented = false
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var formViewModel = FormViewModel()
    
    /// The form being edited in the form view.
    @State private var featureForm: FeatureForm?
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    if isPresented {
                        cancelConfirmationIsShowing = true
                    } else {
                        identifyScreenPoint = screenPoint
                    }
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition,
                       let featureForm = FeatureForm(feature: feature, definition: formDefinition) {
                        self.featureForm = featureForm
                        formViewModel.startEditing(feature, featureForm: featureForm)
                    }
                    isPresented = featureForm != nil
                }
                .ignoresSafeArea(.keyboard)
            
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .leading,
                    isPresented: $isPresented
                ) {
                    FormView(featureForm: featureForm)
                        .padding([.horizontal])
                }
            
                .alert("Cancel editing?", isPresented: $cancelConfirmationIsShowing) {
                    Button("Cancel editing", role: .destructive) {
                        formViewModel.undoEdits()
                        featureForm = nil
                        isPresented = false
                    }
                    Button("Continue editing", role: .cancel) { }
                }
            
                .environmentObject(formViewModel)
                .navigationBarBackButtonHidden(isPresented)
                .toolbar {
                    // Once iOS 16.0 is the minimum supported, the two conditionals to show the
                    // buttons can be merged and hoisted up as the root content of the toolbar.
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isPresented {
                            Button("Cancel", role: .cancel) {
                                formViewModel.undoEdits()
                                isPresented = false
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isPresented {
                            Button("Submit") {
                                Task {
                                    await formViewModel.submitChanges()
                                    isPresented = false
                                }
                            }
                        }
                    }
                }
        }
    }
}

extension FormViewExampleView {
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
