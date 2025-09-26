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

public extension View {
    func featureEditor(
        featureForm: Binding<FeatureForm?>,
        geometryEditor: GeometryEditor,
        mapViewProxy: MapViewProxy? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: featureForm,
                geometryEditor: geometryEditor,
                mapViewProxy: mapViewProxy,
                contentInsets: contentInsets
            )
        )
    }
    
    func featureEditor(
        feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor,
        mapViewProxy: MapViewProxy? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: feature,
                geometryEditor: geometryEditor,
                mapViewProxy: mapViewProxy,
                contentInsets: contentInsets
            )
        )
    }
    
    func featureEditor(
        popup: Binding<Popup?>,
        geometryEditor: GeometryEditor,
        mapViewProxy: MapViewProxy? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: popup,
                geometryEditor: geometryEditor,
                mapViewProxy: mapViewProxy,
                contentInsets: contentInsets
            )
        )
    }
}

private struct FeatureEditorModifier<Item: AnyObject>: ViewModifier {
    @Binding var item: Item?
    let geometryEditor: GeometryEditor
    let mapViewProxy: MapViewProxy?
    let contentInsets: Binding<EdgeInsets?>?
    
    /// This is needed here so that the geometry editor can be stopped outside of FeatureEditorView.
    @State private var model = GeometryEditorModel()
    @State private var featureForm: FeatureForm?
    @State private var isShowingInspector = false
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    @State private var popupIsEditable: Bool = false
    
    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isShowingInspector) {
                VStack(spacing: 0) {
                    if let featureForm {
                        FeatureEditorView(
                            rootFeatureForm: featureForm,
                            model: model,
                            mapViewProxy: mapViewProxy,
                            isPresented: .init(optionalValue: $featureForm),
                            presentationDetent: selectedPresentationDetent
                        )
                        .transition(item is Popup ? .move(edge: .trailing) : .opacity)
                    } else if let popup = item as? Popup {
                        PopupView(root: popup, isPresented: $isShowingInspector)
                            .environment(\.toolbarContent, popupToolbar)
                    }
                }
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { newHeight in
                    contentInsets?.wrappedValue =
                    isShowingInspector && UIDevice.current.userInterfaceIdiom == .phone
                    ? EdgeInsets(top: 0, leading: 0, bottom: newHeight, trailing: 0)
                    : nil
                }
                .onChange(of: featureForm == nil) {
                    guard featureForm == nil else { return }
                    
                    if item is Popup {
                        // Stops the geometry edit if the form is closed back to a popup.
                        // Note: This can't be done in onDisappear, due to lag.
                        model.stop()
                    } else {
                        // Closes the inspector when the feature form is closed,
                        // and it wasn't opened from a popup.
                        isShowingInspector = false
                    }
                }
                .interactiveDismissDisabled()
                .presentationContentInteraction(.scrolls)
                .presentationBackgroundInteraction(.enabled)
                .presentationDetents(
                    [.small, .medium, .large],
                    selection: $selectedPresentationDetent
                )
            }
            .onChange(of: item.map(ObjectIdentifier.init), initial: true) {
                // Displays and hides the inspector based on upstream item changes.
                isShowingInspector = item != nil
            }
            .onChange(of: isShowingInspector) {
                // Handles down stream...
                guard !isShowingInspector else { return }
                
                // Sets item binding to nil, so user can know that the editor has closed.
                item = nil
                
                // Stops the geometry editor. This needs to happen here because onChange won't fire
                // after inspector is closed. This can happen due to upstream item changes.
                // Note: This can't be done in onDisappear, due to lag.
                model.stop()
            }
            .animation(.default, value: isShowingInspector)
            .onChange(of: ObjectIdentifier(geometryEditor), initial: true) {
                model.geometryEditor = geometryEditor
            }
            .onChange(of: item.map(ObjectIdentifier.init)) {
                // Needed to allow feature form to animate when appearing/disappearing.
                featureForm = if let featureForm = item as? FeatureForm {
                    featureForm
                } else if let feature = item as? ArcGISFeature {
                    FeatureForm(feature: feature)
                } else {
                    nil
                }
            }
            .animation(.default, value: featureForm.map(ObjectIdentifier.init))
            .animation(.default, value: item.map(ObjectIdentifier.init))
    }
    
    @ViewBuilder
    private var popupToolbar: some View {
        Spacer()
        Button("Edit", systemImage: "pencil") {
            guard let popup  = item as? Popup,
                  let feature = popup.geoElement as? ArcGISFeature else {
                return
            }
            featureForm = FeatureForm(feature: feature)
        }
        .disabled(!popupIsEditable)
        .task(id: item.map(ObjectIdentifier.init)) {
            if let item = item as? Popup, let feature = item.geoElement as? ArcGISFeature {
                // TODO: Should set to false or true if throws?
                try? await feature.load()
                
                if let table = feature.table {
                    try? await table.load()
                    popupIsEditable = table.isEditable && table.canUpdate(feature)
                } else {
                    // TODO: Correct logic? Should be false instead?
                    popupIsEditable = true
                }
            } else {
                popupIsEditable = false
            }
        }
    }
}


// MARK: - FeatureEditorView

private struct FeatureEditorView: View {
    let rootFeatureForm: FeatureForm
    let model: GeometryEditorModel
    let mapViewProxy: MapViewProxy?
    
    @Binding var isPresented: Bool
    let presentationDetent: PresentationDetent
    
    @State private var backgroundIsIntractable = UIDevice.current.backgroundIsIntractable
    @State private var presentedFeatureForm: FeatureForm?
    @State private var isSaving = false
    
    private var featureForm: FeatureForm { presentedFeatureForm ?? rootFeatureForm }
    private var startEditingID: Int {
        Hasher.hash(ObjectIdentifier(model.geometryEditor), ObjectIdentifier(featureForm))
    }
    
    var body: some View {
        FeatureFormView(root: featureForm, isPresented: $isPresented)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent { event in
                // Stops the geometry editor to make UI seem more responsive.
                model.stop()
                
                if case .savedEdits(let willNavigate) = event {
                    isSaving = false
                    
                    // Closes the inspector when the form footer save button is pressed.
                    guard !willNavigate else { return }
                    isPresented = false
                }
            }
//            .environment(\.canSave, model.canSave)
//            .environment(\.cantSaveMessage, cantSaveMessage)
            .environment(\.beforeSaveAction, save)
            .environment(\.hasExternalEdits, model.canUndo)
            .environment(\.toolbarContent, toolbarContent)
            .task(id: ObjectIdentifier(model.geometryEditor), model.monitorStreams)
            .task(id: startEditingID) {
                let feature = featureForm.feature
                try? await feature.load()
                
                if feature.canUpdateGeometry {
                    if let geometry = feature.geometry {
                        model.start(withInitial: geometry)
                        await mapViewProxy?.setViewpointGeometry(geometry, padding: 20)
                    } else {
                        // TODO: Handle no geometry
                        print("No geometry")
                    }
                } else if model.isStarted {
                    // Stops the geometry editor if the new feature's geometry can't be edited.
                    model.stop()
                    print("Can't edit geometry")
                }
            }
            .task(id: model.geometry) {
                guard model.isStarted, !isSaving, model.geometry != featureForm.feature.geometry else {
                    return
                }
                
                do {
                    // Updates the form when the geometry changes
                    featureForm.feature.geometry = model.geometry
                    try await featureForm.evaluateExpressions()
                } catch {
                    print("Error evaluating expressions: \(error)")
                }
            }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        SnapSettingsButton(snapSettings: model.geometryEditor.snapSettings)
            .disabled(presentationDetent == .large || !backgroundIsIntractable)
            .onReceive(
                NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            ) { _ in
                backgroundIsIntractable = UIDevice.current.backgroundIsIntractable
            }
        Spacer()
    }
    
    private func save() {
        guard model.canUndo else { return }
        
        isSaving = true
        featureForm.feature.geometry = model.save()
    }
    
//    @ViewBuilder
//    private var cantSaveMessage: Text? {
//        if !model.canSave {
//            Text(
//                "The geometry is not valid.",
//                bundle: .toolkitModule,
//                comment: ""
//            )
//        }
//    }
}

private struct SnapSettingsButton: View {
    let snapSettings: SnapSettings
    
    @State private var isPresented = false
    
    var body: some View {
        Button("Snap Settings", systemImage: "gear") {
            do {
                try snapSettings.syncSourceSettings()
                isPresented = true
            } catch {
                print("Error syncing snap source settings: \(error)")
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                SnapSettingsView(model: .init(snapSettings:  snapSettings))
                    .navigationTitle("Snap Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            XButton(.dismiss)
                        }
                    }
            }
        }
    }
}

// MARK: - Extensions

extension EnvironmentValues {
    @Entry var hasExternalEdits = false
    @Entry var toolbarContent: (any View)?
//    @Entry var canSave: Bool?
//    @Entry var cantSaveMessage: Text?
    @Entry var beforeSaveAction: (() -> Void)?
}

private extension PresentationDetent {
    static let small = Self.fraction(0.14)
}

private extension UIDevice {
    var backgroundIsIntractable: Bool {
        userInterfaceIdiom == .phone ? orientation == .portrait : !orientation.isPortrait
    }
}

private extension Hasher {
    static func hash(_ values: AnyHashable...) -> Int {
        var hasher = Hasher()
        for value in values {
            hasher.combine(value)
        }
        return hasher.finalize()
    }
}

private extension Binding where Value == Bool {
    /// Creates a Boolean binding that wraps a binding to an optional.
    ///
    /// `wrappedValue` is `true` when the given optional value is non-`nil`. The
    /// optional value is set to `nil` when the parent binding is set.
    /// - Parameter optionalValue: A binding to the optional value to wrap.
    init<T: Sendable>(optionalValue: Binding<T?>) {
        self.init {
            optionalValue.wrappedValue != nil
        } set: { _ in
            optionalValue.wrappedValue = nil
        }
    }
}
