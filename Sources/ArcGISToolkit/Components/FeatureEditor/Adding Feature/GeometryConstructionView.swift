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

/// A view presented when geometry construction is starting or has stopped.
struct GeometryConstructionView: View {
    /// The selected layer template that will be used to construct the geometry.
    let layerTemplate: LayerTemplate
    
    /// The shared feature editor model.
    @Environment(FeatureAddingModel.self) private var model
    /// An action that dismisses the current presentation.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch model.geometryConstructionState {
            case .stopped, .loading, .editing:
                ProgressView {
                    Text(
                        "Loading geometry construction tools",
                        bundle: .toolkitModule,
                        comment: "A label shown while the construction tools for a feature template are loading."
                    )
                }
                .task {
                    guard model.featureForm == nil else { return }
                    await model.startConstruction(using: layerTemplate)
                }
            case .saving(let geometry):
                ProgressView {
                    Text(
                        "Creating features",
                        bundle: .toolkitModule,
                        comment: "A label shown while a new feature is being created."
                    )
                }
                .task {
                    // This view is displayed briefly before displaying the
                    // feature form view to maintain continuity. We take the
                    // user back to where they were so that they understand what
                    // is going on.
                    
                    // Give the user a little bit of time to read the message.
                    try? await Task.sleep(for: .seconds(0.5))
                    await model.finishSavingConstruction(
                        geometry,
                        layerTemplate: layerTemplate
                    )
                    dismiss()
                }
            case .cancelling:
                Text(
                    "Geometry construction cancelled",
                    bundle: .toolkitModule,
                    comment: "A label shown when the user cancelled geometry construction."
                )
                .task {
                    // This view is displayed briefly and then popped from the
                    // view hierarchy to communicate to maintain continuity.
                    // We take the user back to where they were, and then pop
                    // this view off the navigation stack because it is no
                    // longer needed.
                    
                    // Give the user a little bit of time to read the message.
                    try? await Task.sleep(for: .seconds(0.5))
                    dismiss()
                }
            case .failed(let error):
                switch error {
                case .templateUnavailable(let underlyingError):
                    ContentUnavailableView(
                        LocalizedStringResource(
                            "Template Unavailable",
                            bundle: .toolkit,
                            comment: "The title of a view shown when a shared template fails to load."
                        ),
                        systemImage: "exclamationmark.triangle",
                        description: Text(underlyingError.localizedDescription)
                    )
                case .noSupportedTools:
                    ContentUnavailableView(
                        LocalizedStringResource(
                            "Geometry Construction Not Supported",
                            bundle: .toolkit,
                            comment: "The title of a view shown when a shared template fails to load."
                        ),
                        systemImage: "exclamationmark.triangle",
                        description: Text(
                            "The selected template does not define any supported construction tools.",
                            bundle: .toolkitModule,
                            comment: """
                                A message displayed to the user when a selected template \
                                does not have any supported construction tools.
                                """
                        )
                    )
                case .featureCreationFailed(let underlyingError):
                    ContentUnavailableView(
                        LocalizedStringResource(
                            "Feature Creation Failed",
                            bundle: .toolkit,
                            comment: "The title of a view shown when creating a feature was unsuccessful."
                        ),
                        systemImage: "exclamationmark.triangle",
                        description: Text(underlyingError.localizedDescription)
                    )
                case .noFeatureForm:
                    ContentUnavailableView(
                        LocalizedStringResource(
                            "Feature Form Creation Failed",
                            bundle: .toolkit,
                            comment: "The title of a view shown when creating a feature form was unsuccessful."
                        ),
                        systemImage: "exclamationmark.triangle"
                    )
                }
            }
        }
        .navigationTitle(layerTemplate.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if model.geometryConstructionState == .cancelling {
                model.finishCancellingConstruction()
            }
            if model.geometryConstructionState == .stopped,
               model.selectedLayerTemplate != nil {
                model.selectedLayerTemplate = nil
            }
        }
    }
}
