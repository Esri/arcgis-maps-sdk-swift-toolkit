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

struct FormViewTestView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
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
    
    var body: some View {
        MapView(map: map)
            .onSingleTapGesture { screenPoint, _ in
                identifyScreenPoint = screenPoint
            }
            .task {
                try? await map.load()
                let featureLayer = map.operationalLayers.first as? FeatureLayer
                let parameters = QueryParameters()
                parameters.addObjectID(1)
                let result = try? await featureLayer?.featureTable?.queryFeatures(using: parameters)
                guard let feature = result?.features().makeIterator().next() as? ArcGISFeature else { return }
                try? await feature.load()
                guard let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition else { return }
                featureForm = FeatureForm(feature: feature, definition: formDefinition)
                formViewModel.startEditing(feature)
                isPresented = true
            }
            .ignoresSafeArea(.keyboard)
        
            .floatingPanel(
                selectedDetent: .constant(.full),
                horizontalAlignment: .leading,
                isPresented: $isPresented
            ) {
                FormView(featureForm: featureForm)
                    .padding()
            }
        
            .environmentObject(formViewModel)
            .navigationBarBackButtonHidden(isPresented)
            .toolbar {
                // Once iOS 16.0 is the minimum supported, the two conditionals to show the
                // buttons can be merged and hoisted up as the root content of the toolbar.
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if isPresented && !useControlsInForm {
                        Button("Cancel", role: .cancel) {
                            formViewModel.undoEdits()
                            isPresented = false
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isPresented && !useControlsInForm {
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

private extension FormViewTestView {
    /// A Boolean value indicating whether the form controls should be shown directly in the form's presenting container.
    var useControlsInForm: Bool {
        verticalSizeClass == .compact ||
        UIDevice.current.userInterfaceIdiom == .mac ||
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: <#URL#>)!
    }
}
