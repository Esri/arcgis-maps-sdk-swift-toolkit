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

public extension View {
    /// Presents a Feature Editor view that edits a given feature. Only works
    /// when the `FeatureEditor` view is also created.
    /// - Since: 300.1
    @available(visionOS, unavailable)
    func featureEditorInspector() -> some View {
        modifier(FeatureEditorModifier())
    }
}

/// A view modifier that presents a `FeatureEditorFormView` in an inspector.
@available(visionOS, unavailable)
private struct FeatureEditorModifier: ViewModifier {
    /// The feature editor model shared by the toolbar and inspector.
    @State private var model = FeatureEditorModel()
    /// The inspector's currently selected presentation detent.
    /// This is needed to set the default detent to medium.
    @State private var selectedPresentationDetent = PresentationDetent.medium
    /// A Boolean value indicating whether the feature editor is retrying to start editing.
    @State private var isRetrying = false
    
    func body(content: Content) -> some View {
        content
            .safeInspector(isPresented: $model.isPresented) {
                // VStack is needed for presentation modifiers to be applied.
                VStack(spacing: 0) {
                    switch model.loadResult {
                    case .success:
                        FeatureEditorFormView(isMinimized: selectedPresentationDetent == .bar)
                    case .failure(let error):
                        ContentUnavailableView {
                            Label {
                                Text(
                                    "Failed to start editing",
                                    bundle: .toolkitModule,
                                    comment: "A title shown when feature editing could not start."
                                )
                            } icon: {
                                Image(systemName: "exclamationmark.triangle")
                            }
                        } description: {
                            Text(error.localizedDescription)
                        } actions: {
                            Button {
                                isRetrying = true
                            } label: {
                                Text.tryAgain
                            }
                            .task(id: isRetrying) {
                                guard isRetrying else { return }
                                defer {
                                    // Avoids state updates from cancelled tasks.
                                    if !Task.isCancelled {
                                        isRetrying = false
                                    }
                                }
                                await model.retryStartEditing()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isRetrying)
                            
                            Button {
                                // When the inspector is dismissed, the
                                // feature editor will also stop editing.
                                model.isPresented = false
                            } label: {
                                Text.cancel
                            }
                            .buttonStyle(.bordered)
                        }
                    case .none:
                        ProgressView()
                    }
                }
                .presentationBackgroundInteraction(.enabled)
                .presentationContentInteraction(.scrolls)
                .presentationDetents(
                    [.bar, .medium, .large],
                    selection: $selectedPresentationDetent
                )
#if !targetEnvironment(macCatalyst)
                // Needed to ensure the inspector presents at full width on iPad.
                // This is not done on Mac Catalyst because 320 is smaller than its default.
                .inspectorColumnWidth(ideal: 320)
#endif
                .interactiveDismissDisabled()
                .sheet(isPresented: $model.snapSettingsSheetIsPresented) {
                    SnapSettingsView(settings: model.geometryEditor.snapSettings)
                }
            }
            .environment(model)
    }
}

/// A view that contains the `FeatureFormView` for the feature editor.
private struct FeatureEditorFormView: View {
    /// A Boolean value indicating whether the parent presentation is minimized.
    let isMinimized: Bool
    
    /// The feature editor model from the environment. This is needed to access
    /// the geometry editor.
    @Environment(FeatureEditorModel.self) private var model
    
    /// The form currently presented in the `FeatureFormView`.
    @State private var presentedFeatureForm: FeatureForm?
    
    /// A closure that saves geometry edits to the form's feature. This is
    /// non-`nil` only when there are edits, so the `FeatureFormView`
    /// knows when to show the editing buttons and block navigation.
    private var saveGeometryEditsAction: (() throws -> Void)? {
        guard model.geometryEditorCanUndo else { return nil }
        return {
            guard let geometry = model.geometryEditorGeometry, geometry.sketchIsValid else {
                throw InvalidGeometryError()
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
                .onFormEditingEvent(perform: handleFormEditingEvent)
                .environment(\.externalSaveAction, saveGeometryEditsAction)
                .task(id: presentedFeatureForm.map(ObjectIdentifier.init)) {
                    guard let presentedFeatureForm else { return }
                    defer { self.presentedFeatureForm = nil }
                    await model.startEditingFeatureForm(presentedFeatureForm)
                }
        }
    }
    
    /// Handles events from the `FeatureFormView.onFormEditingEvent(perform:)` modifier.
    /// - Parameter event: The form editing event to handle.
    private func handleFormEditingEvent(_ event: FeatureFormView.EditingEvent) {
        switch event {
        case .discardedEdits(let willNavigate):
            // Restarts the geometry editor when the form footer discard button is pressed.
            guard !willNavigate else { break }
            model.restartGeometryEditor()
        case .savedEdits(let willNavigate):
            // Closes the inspector when the form footer save button is pressed.
            guard !willNavigate else { break }
            model.isPresented = false
        case .showOnMapRequested(let feature):
            model.viewpointGeometry = feature.geometry
        default:
            break
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
    @available(visionOS, unavailable)
    @ViewBuilder
    func safeInspector<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            sheet(isPresented: isPresented, content: content)
        } else {
            // The inspector is given a constant to prevent it from setting isPresented to false
            // when the window is minimized in iPad Stage Manager. Otherwise, the feature editor
            // will stop editing and show an empty inspector when the window is re-expanded.
            inspector(isPresented: .constant(isPresented.wrappedValue), content: content)
        }
    }
}
