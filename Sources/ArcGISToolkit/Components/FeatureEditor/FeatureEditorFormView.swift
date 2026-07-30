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
    /// A Boolean value indicating whether the parent presentation is minimized.
    let isMinimized: Bool
    
    /// The feature editor model from the environment. This is needed to access
    /// the geometry editor.
    @Environment(FeatureEditorModel.self) private var model
    
    /// The current editing event from the form view. This is non-`nil` while
    /// the event is being processed by this view.
    @State private var editingEvent: EquatableEditingEvent?
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
        if let rootFeatureForm = model.rootFeatureForm {
            @Bindable var model = model
            
            FeatureFormView(root: rootFeatureForm, isPresented: $model.isPresented)
                .editingButtons(isMinimized ? .hidden : .automatic)
                .onFeatureFormChanged { presentedFeatureForm = $0 }
                .onFormEditingEvent { editingEvent = EquatableEditingEvent(event: $0) }
                .environment(\.externalSaveAction, saveGeometryEditsAction)
                .onAnimationChange(of: geometryEditorOpacity) { newOpacity in
                    model.geometryEditor.tool.style.opacity = newOpacity
                }
                .animation(.default, value: geometryEditorOpacity)
                .task(id: editingEvent) {
                    guard let editingEvent else { return }
                    await handleEditingEvent(editingEvent.event)
                    
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
                .onDisappear {
                    clearSelectedFeature()
                    model.geometryEditor.tool.style.opacity = 1
                }
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
            model.restartGeometryEditor()
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
    
    /// Zooms to and briefly selects a feature on the map.
    /// - Parameter feature: The `ArcGISFeature` to show.
    private func showFeature(_ feature: ArcGISFeature) async {
        guard feature.geometry?.isEmpty == false else { return }
        
        model.viewpointGeometry = feature.geometry
        
        do {
            try await selectFeature(feature)
        } catch {
            // Sleeps if the geometry editor wasn't hidden so there is still a
            // delay before the selection is cleared.
            try? await Task.sleep(for: .seconds(1))
        }
        
        // Prevents clearing a selection made by another task while this one was still running.
        guard !Task.isCancelled else { return }
        clearSelectedFeature()
    }
    
    /// Selects a feature on the map and briefly hides the geometry editor's symbology.
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
        try? await Task.sleep(for: .seconds(1))
        geometryEditorOpacity = 1
    }
}

// MARK: - Helpers

/// A wrapper for `FeatureFormView.EditingEvent` that conforms to `Equatable`.
private struct EquatableEditingEvent: Equatable {
    /// The form editing event.
    let event: FeatureFormView.EditingEvent
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return switch (lhs.event, rhs.event) {
        case let (.discardedEdits(lhsWillNavigate), .discardedEdits(rhsWillNavigate)):
            lhsWillNavigate == rhsWillNavigate
        case let (.navigationChanged(lhsView), .navigationChanged(rhsView)):
            lhsView == rhsView
        case let (.savedEdits(lhsWillNavigate), .savedEdits(rhsWillNavigate)):
            lhsWillNavigate == rhsWillNavigate
        case let (.showOnMapRequested(lhsFeature), .showOnMapRequested(rhsFeature)):
            lhsFeature === rhsFeature
        default:
            false
        }
    }
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

/// A view modifier that performs an action when the animation data of a given value changes.
private struct OnAnimationChangeModifier<Value: VectorArithmetic>: @MainActor Animatable & ViewModifier {
    /// The value to observe for changes in its animation data.
    let value: Value
    /// The action to perform when the animation data changes.
    let action: (_ animatableData: Value) -> Void
    
    /// The value's animation data that is observed for changes.
    var animatableData: Value {
        get { value }
        set { action(newValue) }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

private extension View {
    /// Performs an action when the animation data of a given value changes.
    /// - Parameters:
    ///   - value: The value to observe for changes in its animation data.
    ///   - action: The action to perform when the animation data changes.
    ///   The new animation data is passed as a parameter.
    func onAnimationChange<Value: VectorArithmetic>(
        of value: Value,
        perform action: @escaping (_ animatableData: Value) -> Void
    ) -> some View {
        modifier(OnAnimationChangeModifier(value: value, action: action))
    }
}
