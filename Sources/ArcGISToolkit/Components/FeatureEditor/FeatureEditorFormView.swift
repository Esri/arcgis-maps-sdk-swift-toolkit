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
internal import os
import SwiftUI

/// A view that contains the `FeatureFormView` for the feature editor.
struct FeatureEditorFormView: View {
    /// The root feature form to display in form view.
    let rootFeatureForm: FeatureForm
    /// A Boolean value indicating whether the parent presentation is minimized.
    let isMinimized: Bool
    
    /// The feature editor model from the environment. This is needed to access
    /// the geometry editor.
    @Environment(FeatureEditorModel.self) private var model
    
    /// The current editing event from the form view. This is non-`nil` while
    /// the event is being processed by this view.
    @State private var editingEvent: FeatureFormView.EditingEvent?
    /// The opacity of the geometry editor tool's symbology. This is used to
    /// animate changes to the geometry editor's opacity.
    @State private var geometryEditorOpacity: Float = 1
    /// The form currently presented in the `FeatureFormView`.
    @State private var presentedFeatureForm: FeatureForm?
    /// The feature currently selected on the map. This is non-`nil` when
    /// adding an association or "Show on Map" is pressed in the form view.
    @State private var selectedFeature: ArcGISFeature?
    
    /// A closure that saves geometry edits to the form's feature. This is
    /// non-`nil` only when there are edits, so the `FeatureFormView`
    /// knows when to show the editing buttons and block navigation.
    private var saveGeometryEditsAction: (() throws -> Void)? {
        guard model.geometryEditorCanUndo else { return nil }
        return {
            guard let geometry = model.geometryEditorGeometry, geometry.sketchIsValid else {
                throw GeometryEditorError.invalidGeometry
            }
            model.feature?.geometry = geometry
        }
    }
    
    var body: some View {
        @Bindable var model = model
        
        FeatureFormView(root: rootFeatureForm, isPresented: $model.isPresented)
            .editingButtons(isMinimized ? .hidden : .automatic)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent { editingEvent = $0 }
            .environment(\.externalSaveAction, saveGeometryEditsAction)
            .onAnimationChange(of: geometryEditorOpacity) { newOpacity in
                model.geometryEditor.tool.style.opacity = newOpacity
            }
            .animation(.default, value: geometryEditorOpacity)
            .task(id: editingEvent) {
                guard let editingEvent else { return }
                await handleEditingEvent(editingEvent)
                
                // Prevents clearing editingEvent if it was set while this
                // task was running.
                guard !Task.isCancelled else { return }
                self.editingEvent = nil
            }
            .task(id: presentedFeatureForm.map(ObjectIdentifier.init)) {
                guard let presentedFeatureForm else { return }
                await model.startEditingFeatureForm(presentedFeatureForm)
                
                // Prevents clearing presentedFeatureForm if it was set
                // while this task was running.
                guard !Task.isCancelled else { return }
                self.presentedFeatureForm = nil
            }
            .task(id: model.geometryEditorGeometry) {
                do {
                    try await model.updateFormGeometry()
                } catch {
                    Logger.featureEditor.error(
                        "Error updating form geometry: \(error.localizedDescription)"
                    )
                }
            }
            .onDisappear {
                clearSelectedFeature()
                model.geometryEditor.tool.style.opacity = 1
            }
    }
    
    /// Clears `selectedFeature` and unselects it on its layer.
    private func clearSelectedFeature() {
        guard let selectedFeature = selectedFeature.take(),
              let layer = selectedFeature.table?.layer as? FeatureSelectableLayer else {
            return
        }
        
        layer.unselectFeature(selectedFeature)
    }
    
    /// Performs an action associated with a form editing event.
    /// - Parameter event: The form editing event to handle.
    private func handleEditingEvent(_ event: FeatureFormView.EditingEvent) async {
        switch event {
        case .discardedEdits(let willNavigate):
            // Restarts the geometry editor when the form footer discard button is pressed.
            guard !willNavigate else { break }
            await model.restartGeometryEditor()
        case .navigationChanged(let view):
            switch view {
            case .utilityAssociationCreationView(_, _, _, let candidate):
                await showCandidate(candidate)
            default:
                // Clears selection when the user navigates away from the current view.
                clearSelectedFeature()
            }
        case .savedEdits(let willNavigate):
            // Closes the inspector when the form footer save button is pressed.
            guard !willNavigate else { break }
            model.isPresented = false
        case .showOnMapRequested(let feature):
            await showFeature(feature)
        }
    }
    
    /// Zooms to and selects an association candidate feature on the map.
    /// - Parameter candidate: The `UtilityAssociationFeatureCandidate` to show.
    private func showCandidate(_ candidate: UtilityAssociationFeatureCandidate) async {
        guard let candidateGeometry = candidate.feature.geometry,
              !candidateGeometry.isEmpty,
              let geometryEditorGeometry = model.geometryEditorGeometry else {
            return
        }
        
        // Sets viewpoint to include the candidate feature and geometry editor geometry,
        // so the user can see what feature they are using to add an association.
        model.viewpointGeometry = GeometryEngine.combineExtents(
            candidateGeometry,
            geometryEditorGeometry
        )
        
        try? await selectFeature(candidate.feature)
    }
    
    /// Zooms to and selects a feature on the map for 1 second.
    /// - Parameter feature: The `ArcGISFeature` to show.
    private func showFeature(_ feature: ArcGISFeature) async {
        guard feature.geometry?.isEmpty == false else { return }
        
        model.viewpointGeometry = feature.geometry
        
        do {
            // Selects the feature and delays for 1 sec while the geometry editor is hidden.
            try await selectFeature(feature)
        } catch {
            // If selectFeature(_:) throws, the feature was selected, but a 1
            // sec delay was not performed since the geometry editor couldn't
            // be hidden. This performs the delay if that happens so that the
            // feature is still selected for one 1 sec.
            try? await Task.sleep(for: .featureHighlightDelay)
        }
        
        // Prevents clearing a selection made by another task while this one was still running.
        guard !Task.isCancelled else { return }
        clearSelectedFeature()
    }
    
    /// Selects a feature on the map and hides the geometry editor's symbology for 1 second.
    /// - Parameter feature: The feature to select.
    /// - Throws: If the geometry editor was not hidden.
    private func selectFeature(_ feature: ArcGISFeature) async throws {
        clearSelectedFeature()
        
        guard let layer = feature.table?.layer as? FeatureSelectableLayer else { return }
        
        layer.selectFeature(feature)
        selectedFeature = feature
        
        // Briefly hides the geometry editor so the user can still locate the
        // selected feature when it's covered by the geometry editor symbology.
        guard let editorGeometry = model.geometryEditorGeometry,
              !editorGeometry.isEmpty,
              let featureGeometry = feature.geometry,
              // Editor geometry is buffered to account for the vertex and line symbols.
              let bufferedGeometry = GeometryEngine.buffer(around: editorGeometry, distance: 10),
              GeometryEngine.isGeometry(featureGeometry, intersecting: bufferedGeometry) else {
            throw GeometryEditorError.notHidden
        }
        
        model.geometryEditor.clearSelection()
        geometryEditorOpacity = 0.1
        try? await Task.sleep(for: .featureHighlightDelay)
        geometryEditorOpacity = 1
    }
}

// MARK: - Helpers

private extension Duration {
    /// The duration before a feature highlight (selection and geometry editor opacity) is cleared.
    static let featureHighlightDelay = Self.seconds(1)
}

/// An error relating to the geometry editor.
private enum GeometryEditorError: LocalizedError {
    /// The geometry editor's geometry is invalid and must be corrected before saving.
    case invalidGeometry
    /// The geometry editor was not hidden when selecting a feature.
    case notHidden
    
    var errorDescription: String? {
        switch self {
        case .invalidGeometry:
            String(
                localized: "The geometry is invalid. It must be corrected before saving.",
                bundle: .toolkitModule,
                comment: "An error message shown when trying to save an invalid geometry."
            )
        case .notHidden:
            nil
        }
    }
}

// MARK: Feature Selectable Layer

/// A layer that can select and unselect a feature.
private protocol FeatureSelectableLayer: Layer {
    func selectFeature(_ feature: Feature)
    func unselectFeature(_ feature: Feature)
}

// Only 2D layers are extended since the Feature Editor is map-specific.
extension AnnotationLayer: FeatureSelectableLayer {}
extension DimensionLayer: FeatureSelectableLayer {}
extension FeatureLayer: FeatureSelectableLayer {}
extension OrientedImageryLayer: FeatureSelectableLayer {}

// MARK: On Animation Change Modifier

/// A view modifier that performs an action when animatable data changes.
private struct OnAnimationChangeModifier<Data: Sendable & VectorArithmetic>: Animatable & ViewModifier {
    /// The data to animate.
    var animatableData: Data {
        didSet { action(animatableData) }
    }
    /// The action to perform when the animatable data changes.
    let action: (_ animatableData: Data) -> Void
    
    func body(content: Content) -> some View {
        content
    }
}

private extension View {
    /// Performs an action when animatable data changes.
    /// - Parameters:
    ///   - animatableData: The data to animate.
    ///   - action: The action to perform when the animatable data changes.
    ///   The new animatable data is passed as a parameter.
    func onAnimationChange<Data: Sendable & VectorArithmetic>(
        of animatableData: Data,
        perform action: @escaping (_ animatableData: Data) -> Void
    ) -> some View {
        modifier(OnAnimationChangeModifier(animatableData: animatableData, action: action))
    }
}
