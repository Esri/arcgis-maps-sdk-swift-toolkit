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
    
    /// The form currently being presented in the `FeatureFormView`.
    @State private var presentedFeatureForm: FeatureForm
    
    /// A value that changes when the geometry editor needs started.
    private var startGeometryEditorID: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(model.geometryEditor))
        hasher.combine(ObjectIdentifier(presentedFeatureForm))
        return hasher.finalize()
    }
    
    init(rootFeatureForm: FeatureForm, isPresented: Binding<Bool>) {
        self.rootFeatureForm = rootFeatureForm
        self._isPresented = isPresented
        self._presentedFeatureForm = State(initialValue: rootFeatureForm)
    }
    
    var body: some View {
        FeatureFormView(root: rootFeatureForm, isPresented: $isPresented)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onChange(of: ObjectIdentifier(rootFeatureForm), initial: true) {
                presentedFeatureForm = rootFeatureForm
            }
            .task(id: startGeometryEditorID, startGeometryEditor)
            .onDisappear {
                // Stops the geometry editor when the feature form is dismissed.
                model.geometryEditor.stop()
            }
    }
    
    /// Starts the geometry editor using the feature form's feature.
    private func startGeometryEditor() async {
        log()
        await loggingError {
            // Stops the geometry editor so it will not continue running if
            // the new feature cannot be edited.
            model.geometryEditor.stop()
            
            // Load needed because canUpdateGeometry is always false otherwise.
            let feature = presentedFeatureForm.feature
            try await feature.load()
            
            guard feature.canUpdateGeometry else { return }
            
            if let geometry = feature.geometry {
                model.geometryEditor.start(withInitial: geometry)
            } else if let featureTable = feature.table {
                // Load needed because geometryType is always nil otherwise.
                try await featureTable.load()
                
                guard let geometryType = featureTable.geometryType else { return }
                model.geometryEditor.start(withType: geometryType)
            }
        }
    }
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
