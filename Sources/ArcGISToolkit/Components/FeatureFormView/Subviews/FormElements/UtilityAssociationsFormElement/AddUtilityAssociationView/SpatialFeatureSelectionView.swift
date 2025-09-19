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

extension FeatureFormView.AddUtilityAssociationView {
    struct SpatialFeatureSelectionView: View {
        /// The view model for the feature form view.
        @Environment(FeatureFormViewModel.self) private var featureFormViewModel
        
        @Environment(FeatureFormView.AddUtilityAssociationView.Model.self) private var addUtilityAssociationViewModel
        
        /// The set of identified/selected features.
        @State private var identifiedFeatures = [ArcGISFeature]()
        
        /// The task to run the feature identification operation in.
        @State private var identifyTask: Task<Void, Never>?
        
        /// A Boolean value indicating whether the identify task is running.
        @State private var identifyTaskIsRunning = false
        
        var body: some View {
            VStack {
                HStack {
                    if identifiedFeatures.isEmpty {
                        Text.tapTheMapToSelectFeatures
                    } else {
                        Text.makeFeaturesSelectedCountLabel(identifiedFeatures.count)
                    }
                    if identifyTaskIsRunning {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
                .onChange(of: featureFormViewModel.mapPoint, initial: false) { _, newValue in
                    if let mapViewProxy = featureFormViewModel.mapViewProxy,
                       let mapPoint = featureFormViewModel.mapPoint,
                       let screenPoint = mapViewProxy.screenPoint(fromLocation: mapPoint) {
                        identifyTask = Task {
                            identifyTaskIsRunning = true
                            defer { identifyTaskIsRunning = false }
                            do {
                                if let identifyLayerResults = try await featureFormViewModel.mapViewProxy?.identifyLayers(
                                    screenPoint: screenPoint,
                                    tolerance: 10
                                ) {
                                    identifiedFeatures = identifyLayerResults.flatMap { result in
                                        result.geoElements.compactMap {
                                            $0 as? ArcGISFeature
                                        }
                                    }
                                }
                            } catch {
#warning("Do identify errors need to be reported to the user?")
                                print(String(reflecting: error))
                            }
                        }
                    }
                }
                HStack {
                    Button {
                        withAnimation {
                            addUtilityAssociationViewModel.spatialFeatureSelectionViewIsPresented = false
                        }
                    } label: {
                        Text.cancel
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.bordered)
                    Button {
                        withAnimation {
                            addUtilityAssociationViewModel.spatialFeatureSelectionViewIsPresented = false
                        }
//                        addUtilityAssociationViewModel.navigationLayerModel?.push {
//                            TabularFeatureSelectionView(
//                                features: identifiedFeatures,
//                                sourceName: nil
//                            )
//                        }
                    } label: {
                        Text.done
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(identifiedFeatures.isEmpty)
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            // TODO: Combine with similar code above and in FeatureFormView.UtilityAssociationDetailsScreen.swift
#if os(visionOS)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
#else
            .background(Color(uiColor: .systemGroupedBackground))
#endif
            .transition(.move(edge: .bottom))
        }
    }
}

private extension Text {
    static func makeFeaturesSelectedCountLabel(_ count: Int) -> Self {
        .init(
            "^[\(count) features](inflect: true) selected",
            bundle: .toolkitModule,
            comment: "The number of features identified from tapping on the map."
        )
    }
    
    static var tapTheMapToSelectFeatures: Self {
        .init(
            "Tap the map to select features",
            bundle: .toolkitModule,
            comment: "A label instructing the user to tap a feature on the map."
        )
    }
}
