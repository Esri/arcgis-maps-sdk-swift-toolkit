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

public extension View {
    func featureEditor(
        _ feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor
    ) -> some View {
        modifier(FeatureEditorModifier(feature, geometryEditor: geometryEditor))
    }
}

private struct FeatureEditorModifier: ViewModifier {
    @Binding private var feature: ArcGISFeature?
    private let geometryEditor: GeometryEditor
    
    @State private var model: FeatureEditorModel
    /// The inspector's currently presentation selected detent. This is needed to set the default detent to medium.
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    private var isPresented: Binding<Bool> {
        Binding(get: { feature != nil }, set: { _ in feature = nil })
    }
    
    init(_ feature: Binding<ArcGISFeature?>, geometryEditor: GeometryEditor) {
        self._feature = feature
        self.geometryEditor = geometryEditor
        self._model = State(initialValue: FeatureEditorModel(geometryEditor: geometryEditor))
    }
    
    func body(content: Content) -> some View {
        content
            .inspector(isPresented: isPresented) {
                // VStack needed for presentation modifiers to be applied.
                VStack(spacing: 0) {
                    if let feature {
                        FeatureEditorView(
                            rootFeatureForm: FeatureForm(feature: feature),
                            isPresented: isPresented
                        )
                    }
                }
                .presentationBackgroundInteraction(.enabled)
                .presentationContentInteraction(.scrolls)
                .presentationDetents(
                    [.bar, .medium, .large],
                    selection: $selectedPresentationDetent
                )
                .inspectorColumnWidth(ideal: 320)
                .interactiveDismissDisabled()
            }
            .environment(model)
            .onChange(of: ObjectIdentifier(geometryEditor)) {
                model.geometryEditor = geometryEditor
            }
    }
}

private struct FeatureEditorView: View {
    /// The root feature form to display in the `FeatureFormView`.
    private let rootFeatureForm: FeatureForm
    @Binding private var isPresented: Bool
    
    @Environment(FeatureEditorModel.self) private var model
    
    /// A Boolean value indicating whether the geometry editor has edits to undo.
    @State private var canUndo = false
    /// The geometry editor's current geometry.
    @State private var geometry: Geometry?
    /// The form currently being presented in the `FeatureFormView`.
    @State private var presentedFeatureForm: FeatureForm
    
    /// A value that changes when the geometry editor needs started.
    private var startGeometryEditorID: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(model.geometryEditor))
        hasher.combine(ObjectIdentifier(presentedFeatureForm))
        return hasher.finalize()
    }
    
    /// A closure that saves geometry edits to the form's feature. This is non-`nil` only when
    /// `canUndo` is `true` to indicate to the `FeatureFormView` when there are edits.
    private var saveGeometryEditsAction: (() throws -> Void)? {
        guard canUndo else { return nil }
        return {
            log()
            guard let geometry, geometry.sketchIsValid else {
                throw InvalidGeometryError()
            }
            presentedFeatureForm.feature.geometry = geometry
        }
    }
    
    init(rootFeatureForm: FeatureForm, isPresented: Binding<Bool>) {
        self.rootFeatureForm = rootFeatureForm
        self._isPresented = isPresented
        self._presentedFeatureForm = State(initialValue: rootFeatureForm)
    }
    
    var body: some View {
        FeatureFormView(root: rootFeatureForm, isPresented: $isPresented)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent(perform: handleFormEditingEvent)
            .environment(\.externalSaveAction, saveGeometryEditsAction)
            .onChange(of: ObjectIdentifier(rootFeatureForm), initial: true) {
                presentedFeatureForm = rootFeatureForm
            }
            .task(id: ObjectIdentifier(model.geometryEditor), monitorGeometryEditorStreams)
            .task(id: startGeometryEditorID) {
                await loggingError {
                    // Stops the geometry editor so it will not continue running if
                    // the new feature cannot be edited.
                    model.geometryEditor.stop()
                    
                    try await loadFeature()
                    startGeometryEditor()
                }
            }
            .onDisappear {
                // Stops the geometry editor when the feature form is dismissed.
                model.geometryEditor.stop()
            }
    }
    
    /// Handles events from the `FeatureFormView.onFormEditingEvent(perform:)`.
    /// - Parameter event: The form editing event to handle.
    private func handleFormEditingEvent(_ event: FeatureFormView.EditingEvent) {
        log()
        switch event {
        case .savedEdits(let willNavigate):
            // Closes the inspector when the form footer save button is pressed.
            guard !willNavigate else { break }
            isPresented = false
        case .discardedEdits(let willNavigate):
            // Restarts the geometry editor when the form footer discard button is pressed.
            guard !willNavigate else { break }
            startGeometryEditor()
        default:
            break
        }
    }
    
    /// Loads the form's feature and its properties needed to start the geometry editor.
    private func loadFeature() async throws {
        log()
        // Loads the feature so that canUpdateGeometry can be accessed.
        // It is false otherwise.
        let feature = presentedFeatureForm.feature
        try await feature.load()
        
        // Loads the feature's table if the geometry is nil so that
        // geometryType can be accessed. It is nil otherwise.
        guard feature.canUpdateGeometry, feature.geometry == nil, let table = feature.table else {
            return
        }
        try await table.load()
    }
    
    /// Monitors geometry editor streams and updates the corresponding state properties.
    private func monitorGeometryEditorStreams() async {
        log()
        let geometryEditor = model.geometryEditor
        await withTaskGroup { group in
            group.addTask { @MainActor @Sendable in
                for await canUndo in geometryEditor.$canUndo {
                    self.canUndo = canUndo
                }
            }
            group.addTask { @MainActor @Sendable in
                for await geometry in geometryEditor.$geometry {
                    self.geometry = geometry
                }
            }
        }
    }
    
    /// Starts the geometry editor using the form's feature.
    private func startGeometryEditor() {
        log()
        let feature = presentedFeatureForm.feature
        guard feature.canUpdateGeometry else { return }
        
        if let geometry = feature.geometry {
            model.geometryEditor.start(withInitial: geometry)
        } else if let geometryType = feature.table?.geometryType {
            model.geometryEditor.start(withType: geometryType)
        }
    }
}

/// An error indicating that the geometry is invalid and must be corrected before saving.
private struct InvalidGeometryError: LocalizedError {
    let errorDescription: String? = String(
        localized: "The geometry is invalid. It must be corrected before saving.",
        bundle: .toolkitModule,
        comment: "An error message shown when trying to save an invalid geometry."
    )
}

// MARK: - Bar Detent

/// A custom presentation detent that sizes to the approximate height of a top system toolbar.
private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Implementation copied from:
        // https://developer.apple.com/documentation/swiftui/custompresentationdetent#overview
        return max(44, context.maxDetentValue * 0.1)
    }
}

private extension PresentationDetent {
    /// A custom presentation detent that sizes to the approximate height of a top system toolbar.
    static let bar = Self.custom(BarDetent.self)
}
