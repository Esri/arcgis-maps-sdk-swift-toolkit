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
import OSLog
import SwiftUI

public extension View {
    /// Presents a Feature Editor view that edits a given feature. Only works
    /// when the `FeatureEditor` view is also created.
    /// - Since: 300.1
    @available(visionOS, unavailable)
    func featureEditorInspector() -> some View {
        modifier(FeatureEditorModifier())
    }
}

/// A view modifier that presents a `FeatureEditorView` in an inspector when
/// a feature is non-`nil`.
@available(visionOS, unavailable)
private struct FeatureEditorModifier: ViewModifier {
    /// The feature editor model shared by the toolbar and inspector.
    @State private var model = FeatureEditorModel()
    /// The inspector's currently selected presentation detent.
    /// This is needed to set the default detent to medium.
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    /// A binding to a Boolean value that indicates whether the inspector should be presented.
    /// This maps `model.featureForm` to a Boolean value.
    private var isPresented: Binding<Bool> {
        Binding { model.featureForm != nil } set: { _ in model.featureForm = nil }
    }
    
    func body(content: Content) -> some View {
        content
            .safeInspector(isPresented: isPresented) {
                // VStack is needed for presentation modifiers to be applied.
                VStack(spacing: 0) {
                    if let featureForm = model.featureForm {
                        FeatureEditorView(
                            featureForm: featureForm,
                            isPresented: isPresented,
                            isMinimized: selectedPresentationDetent == .bar
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
            .onChange(of: isPresented.wrappedValue) {
                // Stops the geometry editor when the inspector is dismissed.
                // This is done in an onChange modifier to sync the stop with
                // the inspector's disappearance (onDisappear is too slow).
                // It needs to happen outside of the inspector since onChange
                // doesn't fire before it is dismissed on some platforms.
                model.geometryEditor.stop()
            }
    }
}

/// A view that displays a `FeatureFormView` and manages a geometry editor for editing a feature.
private struct FeatureEditorView: View {
    /// The root feature form to display in the `FeatureFormView`.
    private let rootFeatureForm: FeatureForm
    /// A Boolean value indicating whether the view is presented.
    @Binding private var isPresented: Bool
    /// The feature editor model from the environment. This is needed to access
    /// the geometry editor.
    @Environment(FeatureEditorModel.self) private var model
    /// A Boolean value indicating whether the parent presentation is minimized.
    private let isMinimized: Bool
    
    /// The form currently presented in the `FeatureFormView`.
    @State private var presentedFeatureForm: FeatureForm
    
    /// A value that changes when the geometry editor needs to be started.
    private var startGeometryEditorID: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(model.geometryEditor))
        hasher.combine(ObjectIdentifier(presentedFeatureForm))
        return hasher.finalize()
    }
    
    /// A closure that saves geometry edits to the form's feature. This is non-`nil` only when
    /// `canUndo` is `true` to indicate to the `FeatureFormView` when there are edits.
    private var saveGeometryEditsAction: (() throws -> Void)? {
        guard model.geometryEditorCanUndo else { return nil }
        return {
            guard let geometry = model.geometryEditorGeometry, geometry.sketchIsValid else {
                throw InvalidGeometryError()
            }
            presentedFeatureForm.feature.geometry = geometry
        }
    }
    
    init(featureForm: FeatureForm, isPresented: Binding<Bool>, isMinimized: Bool) {
        self.rootFeatureForm = featureForm
        self._isPresented = isPresented
        self._presentedFeatureForm = State(initialValue: rootFeatureForm)
        self.isMinimized = isMinimized
    }
    
    var body: some View {
        FeatureFormView(root: rootFeatureForm, isPresented: $isPresented)
            .editingButtons(isMinimized ? .hidden : .automatic)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent(perform: handleFormEditingEvent)
            .environment(\.externalSaveAction, saveGeometryEditsAction)
            .onChange(of: ObjectIdentifier(rootFeatureForm), initial: true) {
                presentedFeatureForm = rootFeatureForm
            }
            .task(id: startGeometryEditorID) {
                do {
                    // Stops the geometry editor so it will not continue running if
                    // the new feature cannot be edited.
                    model.geometryEditor.stop()
                    
                    try await loadFeature()
                    startGeometryEditor()
                } catch {
                    Logger.featureEditor.error(
                        "Error starting geometry editor: \(String(describing: error))"
                    )
                }
            }
    }
    
    /// Handles events from the `FeatureFormView.onFormEditingEvent(perform:)` modifier.
    /// - Parameter event: The form editing event to handle.
    private func handleFormEditingEvent(_ event: FeatureFormView.EditingEvent) {
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
        // Loads the feature so that canUpdateGeometry can be accessed. It is false otherwise.
        let feature = presentedFeatureForm.feature
        try await feature.load()
        
        // Loads the feature's table if the geometry is nil so that geometryType can be accessed.
        // It is nil otherwise.
        guard feature.canUpdateGeometry, feature.geometry == nil, let table = feature.table else {
            return
        }
        try await table.load()
    }
    
    /// Starts the geometry editor using the form's feature.
    private func startGeometryEditor() {
        let feature = presentedFeatureForm.feature
        guard feature.canUpdateGeometry else { return }
        
        if let geometry = feature.geometry {
            model.geometryEditor.start(withInitial: geometry)
        } else if let geometryType = feature.table?.geometryType {
            model.geometryEditor.start(withType: geometryType)
        }
    }
}

// MARK: - Helper Types

/// A custom presentation detent that sizes to the approximate height of a top system toolbar.
private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Implementation copied from:
        // https://developer.apple.com/documentation/swiftui/custompresentationdetent#overview
        return max(44, context.maxDetentValue * 0.1)
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

// MARK: - Extensions

private extension Logger {
    /// A logger for the Feature Editor.
    static var featureEditor: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureEditor")
    }
}

private extension PresentationDetent {
    /// A custom presentation detent that sizes to the approximate height of a top system toolbar.
    static let bar = Self.custom(BarDetent.self)
}

private extension View {
    /// Presents content in a sheet on iPhone and in an inspector on all other devices.
    ///
    /// This is needed because the `View.presentationDetents(_:selection:)`
    /// selection value does not update with inspectors.
    /// - Parameters:
    ///   - isPresented: A Boolean value indicating whether the inspector is presented.
    ///   - content: The content to display in the inspector.
    @ViewBuilder
    func safeInspector<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            sheet(isPresented: isPresented, content: content)
        } else {
            inspector(isPresented: isPresented, content: content)
        }
    }
}
