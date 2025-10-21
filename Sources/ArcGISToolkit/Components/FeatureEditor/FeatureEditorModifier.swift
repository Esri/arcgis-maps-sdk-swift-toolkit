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
        feature: Binding<ArcGISFeature?>,
        geometryEditor: GeometryEditor,
        viewpoint: Binding<Viewpoint?>? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: feature,
                geometryEditor: geometryEditor,
                viewpoint: viewpoint,
                contentInsets: contentInsets
            )
        )
    }
    
    func featureEditor(
        featureForm: Binding<FeatureForm?>,
        geometryEditor: GeometryEditor,
        viewpoint: Binding<Viewpoint?>? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: featureForm,
                geometryEditor: geometryEditor,
                viewpoint: viewpoint,
                contentInsets: contentInsets
            )
        )
    }
    
    func featureEditor(
        popup: Binding<Popup?>,
        geometryEditor: GeometryEditor,
        viewpoint: Binding<Viewpoint?>? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: popup,
                geometryEditor: geometryEditor,
                viewpoint: viewpoint,
                contentInsets: contentInsets
            )
        )
    }
}

private struct FeatureEditorModifier<Item: AnyObject>: ViewModifier {
    @Binding var item: Item?
    let geometryEditor: GeometryEditor
    let viewpoint: Binding<Viewpoint?>?
    let contentInsets: Binding<EdgeInsets?>?
    
    @State private var featureForm: FeatureForm?
    @State private var isShowingInspector = false
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    func body(content: Content) -> some View {
        content
            .inspector(isPresented: $isShowingInspector) {
                VStack(spacing: 0) {
                    if let featureForm {
                        FeatureEditorView(
                            rootFeatureForm: featureForm,
                            geometryEditor: geometryEditor,
                            viewpoint: viewpoint,
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
                        print("stop", FileLocation())
                        geometryEditor.stop()
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
                print("stop", FileLocation())
                geometryEditor.stop()
            }
            .animation(.default, value: isShowingInspector)
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
    }
}


// MARK: - FeatureEditorView

private struct FeatureEditorView: View {
    let rootFeatureForm: FeatureForm
    let geometryEditor: GeometryEditor
    let viewpoint: Binding<Viewpoint?>?
    
    @Binding var isPresented: Bool
    let presentationDetent: PresentationDetent
    
    @State private var backgroundIsIntractable = UIDevice.current.backgroundIsIntractable
    @State private var presentedFeatureForm: FeatureForm?
    @State private var isSaving = false
    
    @State private var isStarted = false
    @State private var canUndo = false
    @State private var geometry: Geometry?
    
    private var featureForm: FeatureForm { presentedFeatureForm ?? rootFeatureForm }
    
    var body: some View {
        FeatureFormView(root: featureForm, isPresented: $isPresented)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent { event in
                // Stops the geometry editor in preparation for startEditing() to run again
                // and to make UI seem more responsive.
                print("stop", FileLocation())
                geometryEditor.stop()
                
                if case .savedEdits(let willNavigate) = event {
                    isSaving = false
                    
                    // Closes the inspector when the form footer save button is pressed.
                    guard !willNavigate else { return }
                    isPresented = false
                }
            }
            .environment(\.canSave, geometry?.sketchIsValid)
//            .environment(\.cantSaveMessage, cantSaveMessage)
            .environment(\.beforeSaveAction, save)
            .environment(\.hasExternalEdits, canUndo)
            .environment(\.toolbarContent, toolbarContent)
            .task(id: ObjectIdentifier(geometryEditor), monitorGeometryEditorStreams)
            .task(
                id: Hasher.hash(ObjectIdentifier(geometryEditor), ObjectIdentifier(featureForm)),
                startGeometryEditor
            )
            .task(id: geometry, updateFeatureFormGeometry)
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        SnapSettingsButton(settings: geometryEditor.snapSettings)
            .disabled(!isStarted || presentationDetent == .large || !backgroundIsIntractable)
            .onReceive(
                NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            ) { _ in
                backgroundIsIntractable = UIDevice.current.backgroundIsIntractable
            }
        Spacer()
    }
    
    /// Monitors geometry editor streams and updates the corresponding state properties.
    private func monitorGeometryEditorStreams() async {
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
            group.addTask { @MainActor @Sendable in
                for await isStarted in geometryEditor.$isStarted {
                    self.isStarted = isStarted
                }
            }
        }
    }
    
    /// Starts the geometry editor using the feature form's feature.
    private func startGeometryEditor() async {
        do {
            // Load needed because canUpdateGeometry is always false otherwise.
            let feature = featureForm.feature
            try await feature.load()
            
            if let buffer = feature.geometry?.extent.withBuilder({ $0.expand(by: 1.1) }),
               !buffer.isEmpty {
                viewpoint?.wrappedValue = Viewpoint(boundingGeometry: buffer)
            }
            
            guard feature.canUpdateGeometry else { return }
            
            if let geometry = feature.geometry {
                print("start(withInitial:)", FileLocation())
                geometryEditor.start(withInitial: geometry)
            } else if let featureTable = feature.table {
                // Load needed because geometryType is always nil otherwise.
                try await featureTable.load()
                
                guard let geometryType = featureTable.geometryType else { return }
                print("start(withType:)", FileLocation())
                geometryEditor.start(withType: geometryType)
            }
        } catch {
            print("FE error starting: \(error)")
        }
    }
    
    /// Set's feature form's geometry and calls `evaluateExpressions`.
    ///
    /// This is needed update any geometry dependent form elements when the geometry changes.
    private func updateFeatureFormGeometry() async {
        guard geometryEditor.isStarted, !isSaving, geometry != featureForm.feature.geometry else {
            return
        }
        
        do {
            print("form geometry", FileLocation())
            featureForm.feature.geometry = geometry
            try await featureForm.evaluateExpressions()
        } catch {
            print("FE error evaluating expressions: \(error)")
        }
    }
    
    private func save() {
        guard canUndo else { return }
        
        isSaving = true
        print("save", FileLocation())
        featureForm.feature.geometry = geometry
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

/// A button that presents a view for configuring given `SnapSettings`.
private struct SnapSettingsButton: View {
    /// The snap settings to configure.
    let settings: SnapSettings
    
    /// A Boolean value indicating whether the error alert is presented.
    @State private var errorAlertIsPresented = false
    /// A Boolean value indicating whether the snap settings view is presented.
    @State private var snapSettingsArePresented = false
    /// An error thrown while syncing snap settings.
    @State private var syncingError: (any Error)?
    
    var body: some View {
        Button("Snapping Settings", systemImage: "gear") {
            do {
                try settings.syncSourceSettings()
                snapSettingsArePresented = true
            } catch {
                syncingError = error
                errorAlertIsPresented = true
            }
        }
        .sheet(isPresented: $snapSettingsArePresented) {
            NavigationStack {
                SnapSettingsView(settings: settings)
                    .navigationTitle("Snapping Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            XButton(.dismiss)
                        }
                    }
            }
        }
        .alert("Error Syncing Snap Settings", isPresented: $errorAlertIsPresented, actions: {}) {
            if let syncingError {
                Text(syncingError.localizedDescription)
            }
        }
    }
}

// MARK: - Extensions

extension EnvironmentValues {
    @Entry var hasExternalEdits = false
    @Entry var toolbarContent: (any View)?
    @Entry var canSave: Bool?
//    @Entry var cantSaveMessage: Text?
    @Entry var beforeSaveAction: (() -> Void)?
}

private extension PresentationDetent {
    // TODO: set based on navigation title?
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

// MARK: - Debug

struct FileLocation: CustomDebugStringConvertible {
    let file: NSString
    let line: UInt
    let function: StaticString
    
    init(
        file: NSString = #filePath,
        line: UInt = #line,
        function: StaticString = #function
    ) {
        self.file = file
        self.line = line
        self.function = function
    }
    
    var debugDescription: String {
        "\(file.lastPathComponent):\(line) \(function)"
    }
}
