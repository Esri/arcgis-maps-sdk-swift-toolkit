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

struct FormViewExampleView: View {
    @Environment(\.isPortraitOrientation)
    private var isPortraitOrientation
    
    /// The size of the usable area provided to the `FormView`.
    ///
    /// Use this to help avoid covering the feature being edited with the form.
    @State private var contentSize: CGSize?
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// A Boolean value indicating whether the alert confirming the user's intent to cancel is displayed.
    @State private var isCancelConfirmationPresented = false
    
    /// A Boolean value indicating whether or not the form is displayed.
    @State private var isFormPresented = false
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var formViewModel = FormViewModel()
    
    /// The form being edited in the form view.
    @State private var featureForm: FeatureForm? {
        didSet {
            isFormPresented = featureForm != nil
        }
    }
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    if isFormPresented {
                        isCancelConfirmationPresented = true
                    } else {
                        identifyScreenPoint = screenPoint
                    }
                }
                .contentInsets(
                    .init(
                        top: .zero,
                        leading: isFormPresented && !isPortraitOrientation ? contentSize?.width ?? .zero : .zero,
                        bottom: isFormPresented && isPortraitOrientation && detent != .full ? contentSize?.height ?? .zero : .zero,
                        trailing: .zero
                    )
                )
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition,
                       let featureForm = FeatureForm(feature: feature, definition: formDefinition) {
                        self.featureForm = featureForm
                        formViewModel.startEditing(feature, featureForm: featureForm)
                        if let geometry = feature.geometry {
                            await mapViewProxy.setViewpoint(
                                Viewpoint(boundingGeometry: geometry)
                            )
                        }
                    }
                }
                .ignoresSafeArea(.keyboard)
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .leading,
                    isPresented: $isFormPresented
                ) {
                    GeometryReader { geometryProxy in
                        FormView(featureForm: featureForm)
                            .padding([.horizontal])
                            .onChange(of: geometryProxy.size) {
                                contentSize = $0
                            }
                    }
                }
                .alert("Discard edits", isPresented: $isCancelConfirmationPresented) {
                        Button("Discard edits", role: .destructive) {
                            formViewModel.undoEdits()
                            featureForm = nil
                        }
                        Button("Continue editing", role: .cancel) { }
                } message: {
                    Text("Updates to this feature will be lost.")
                }
                .environmentObject(formViewModel)
                .navigationBarBackButtonHidden(isFormPresented)
                .toolbar {
                    // Once iOS 16.0 is the minimum supported, the two conditionals to show the
                    // buttons can be merged and hoisted up as the root content of the toolbar.
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isFormPresented {
                            Button("Cancel", role: .cancel) {
                                isCancelConfirmationPresented = true
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isFormPresented {
                            Button("Submit") {
                                Task {
                                    await formViewModel.submitChanges()
                                    featureForm = nil
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
