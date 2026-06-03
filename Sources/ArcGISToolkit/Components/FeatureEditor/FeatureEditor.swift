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
        item: Binding<(any FeatureEditorItem)?>,
        geometryEditor: GeometryEditor,
        viewpoint: Binding<Viewpoint?>? = nil,
        contentInsets: Binding<EdgeInsets?>? = nil
    ) -> some View {
        modifier(
            FeatureEditorModifier(
                item: item,
                geometryEditor: geometryEditor,
                viewpoint: viewpoint,
                contentInsets: contentInsets
            )
        )
    }
}

// TODO: Remove and replace with multiple overloads?
/// An object that can be displayed and/or edited by the Feature Editor.
public protocol FeatureEditorItem: AnyObject {}

extension ArcGISFeature: FeatureEditorItem {}
extension FeatureForm: FeatureEditorItem {}
extension Popup: FeatureEditorItem {}

private struct FeatureEditorModifier: ViewModifier {
    @Binding var item: (any FeatureEditorItem)?
    let geometryEditor: GeometryEditor
    let viewpoint: Binding<Viewpoint?>?
    let contentInsets: Binding<EdgeInsets?>?
    
    @State private var featureForm: FeatureForm?
    @State private var isShowingInspector = false
    /// A binding to the inspector's currently presentation selected detent.
    ///
    /// This is needed to set the default detent to medium.
    @State private var selectedPresentationDetent = PresentationDetent.medium
    
    func body(content: Content) -> some View {
        content
            .inspector(
                // Workaround for bug where inspector sometimes sets the binding on init
                // which prevents it from appearing when the binding is later set.
                isPresented: isShowingInspector ? $isShowingInspector : .constant(false)
            ) {
                VStack(spacing: 0) {
                    if let featureForm {
                        FeatureEditorView(
                            rootFeatureForm: featureForm,
                            geometryEditor: geometryEditor,
                            viewpoint: viewpoint,
                            isPresented: Binding(optionalValue: $featureForm)
                        )
                        .transition(item is Popup ? .move(edge: .trailing) : .opacity)
                    } else if let popup = item as? Popup {
                        PopupView(root: popup, isPresented: $isShowingInspector)
                            .environment(\.bottomToolbarContent, popupToolbar)
                    }
                }
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { newHeight in
                    // TODO: Horizontal insets needed for iPad and Mac Cat?
                    contentInsets?.wrappedValue =
                    isShowingInspector && UIDevice.current.userInterfaceIdiom == .phone
                    ? EdgeInsets(top: 0, leading: 0, bottom: newHeight, trailing: 0)
                    : nil
                }
                .onChange(of: featureForm == nil) {
                    guard featureForm == nil else { return }
                    
                    if item is Popup {
                        // Stops the geometry edit if the form is closed back to a popup.
                        // This can't be done in onDisappear, due to lag.
                        geometryEditor.stop()
                    } else {
                        // Closes the inspector when the feature form is closed,
                        // and it wasn't opened from a popup.
                        isShowingInspector = false
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
                // This can't be done in onDisappear, due to lag.
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
    
    /// The toolbar to show on the `PopupView`.
    @ViewBuilder
    private var popupToolbar: some View {
        Spacer()
        Button("Edit", systemImage: "pencil") {
            guard let popup  = item as? Popup,
                  let feature = popup.geoElement as? ArcGISFeature else {
                return
            }
            featureForm = FeatureForm(feature: feature)
            selectedPresentationDetent = .medium
        }
    }
}


// MARK: - FeatureEditorView

private struct FeatureEditorView: View {
    /// The root feature form to display in the `FeatureFormView`.
    private let rootFeatureForm: FeatureForm
    /// The geometry editor to use for geometry editing.
    private let geometryEditor: GeometryEditor
    
    
    private let viewpoint: Binding<Viewpoint?>?
    @Binding private var isPresented: Bool
    @State private var presentedFeatureForm: FeatureForm
    
    /// A Boolean value indicating whether the geometry editor has edits to undo.
    @State private var canUndo = false
    /// The geometry editor's current geometry.
    @State private var geometry: Geometry?
    /// A Boolean value indicating whether the edits are currently being saved.
    @State private var isSaving = false
    /// A Boolean value indicating whether the geometry editor has started.
    @State private var isStarted = false
    
    /// A hash value that changes when the geometry editor needs started.
    private var startGeometryEditorHash: Int {
        var hasher = Hasher()
        hasher.combine(ObjectIdentifier(geometryEditor))
        hasher.combine(ObjectIdentifier(presentedFeatureForm))
        return hasher.finalize()
    }
    
    init(
        rootFeatureForm: FeatureForm,
        geometryEditor: GeometryEditor,
        viewpoint: Binding<Viewpoint?>?,
        isPresented: Binding<Bool>
    ) {
        self.rootFeatureForm = rootFeatureForm
        self.geometryEditor = geometryEditor
        self.viewpoint = viewpoint
        self._isPresented = isPresented
        self._presentedFeatureForm = State(initialValue: rootFeatureForm)
    }
    
    var body: some View {
        FeatureFormView(root: rootFeatureForm, isPresented: $isPresented)
            .onFeatureFormChanged { presentedFeatureForm = $0 }
            .onFormEditingEvent(perform: handleFormEditingEvent)
            .environment(\.beforeSaveAction, save)
            .environment(\.hasEdits, canUndo)
            .environment(\.validationErrorMessage, invalidGeometryMessage)
            .onChange(of: ObjectIdentifier(rootFeatureForm), initial: true) {
                presentedFeatureForm = rootFeatureForm
            }
            .task(id: ObjectIdentifier(geometryEditor), monitorGeometryEditorStreams)
            .task(id: startGeometryEditorHash, startGeometryEditor)
            .task(id: geometry, updateFeatureFormGeometry)
    }
    
    /// The text for indicating that the geometry editor's geometry is invalid.
    @ViewBuilder
    private var invalidGeometryMessage: Text? {
        if geometry?.sketchIsValid != true {
            Text(
                "The geometry is invalid. It must be corrected before saving.",
                bundle: .toolkitModule,
                comment: ""
            )
        }
    }
    
    /// Monitors geometry editor streams and updates the corresponding state properties.
    private func monitorGeometryEditorStreams() async {
        log()
        
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
        log()
        
        geometryEditor.stop()
        
        do {
            // Load needed because canUpdateGeometry is always false otherwise.
            let feature = presentedFeatureForm.feature
            try await feature.load()
            
            centerViewpoint(on: feature)
            
            guard feature.canUpdateGeometry else { return }
            
            if let geometry = feature.geometry {
                geometryEditor.start(withInitial: geometry)
            } else if let featureTable = feature.table {
                // Load needed because geometryType is always nil otherwise.
                try await featureTable.load()
                
                guard let geometryType = featureTable.geometryType else { return }
                geometryEditor.start(withType: geometryType)
            }
            
            // TODO: Remove?
            if let snapRules = try await snapRules(for: feature) {
                try geometryEditor.snapSettings.syncSourceSettings(
                    rules: snapRules,
                    sourceEnablingBehavior: .setFromRules
                )
            } else {
                try geometryEditor.snapSettings.syncSourceSettings()
            }
        } catch {
            print("FE error starting: \(error)")
        }
    }
    
    /// Set's feature form's geometry and calls `evaluateExpressions`.
    ///
    /// This is needed update any geometry dependent form elements when the geometry changes.
    private func updateFeatureFormGeometry() async {
        log()
        
        guard isStarted, !isSaving, geometry != presentedFeatureForm.feature.geometry else {
            return
        }
        
        do {
            presentedFeatureForm.feature.geometry = geometry
            try await presentedFeatureForm.evaluateExpressions()
        } catch {
            print("FE error evaluating expressions: \(error)")
        }
    }
    
    private func save() {
        log()
        guard canUndo else { return }
        
        isSaving = true
        presentedFeatureForm.feature.geometry = geometry
    }
    
    private func handleFormEditingEvent(_ event: FeatureFormView.EditingEvent) {
        log()
        
        switch event {
        case .savedEdits(let willNavigate):
            isSaving = false
            
            // Closes the inspector when the form footer save button is pressed.
            guard !willNavigate else { return }
            isPresented = false
            
        case .showOnMapRequested(let feature):
            centerViewpoint(on: feature)
            
        default:
            break
        }
    }
    
    private func centerViewpoint(on feature: Feature) {
        log()
        
        guard let viewpoint,
              let buffer = feature.geometry?.extent.withBuilder({ $0.expand(by: 1.2) }),
              !buffer.isEmpty else {
            return
        }
        viewpoint.wrappedValue = Viewpoint(boundingGeometry: buffer)
    }
    
    // TODO: Remove?
    private func snapRules(for feature: ArcGISFeature) async throws -> SnapRules? {
        guard let table = feature.table else { return nil }
        
        try await table.load()
        
        if let serviceFeatureTable = feature.table as? ServiceFeatureTable,
           let serviceGeodatabase = serviceFeatureTable.serviceGeodatabase {
            let utilityNetwork = UtilityNetwork(serviceGeodatabase: serviceGeodatabase)
            try await utilityNetwork.load()
            
            if let element = utilityNetwork.makeElement(arcGISFeature: feature) {
                print("🔹", "[serviceGeodatabase - element]", ObjectIdentifier(utilityNetwork))
                return try await .rules(for: utilityNetwork, assetType: element.assetType)
            } else {
                print("🔹", "[serviceGeodatabase - table]", ObjectIdentifier(utilityNetwork))
                return try await .rules(
                    for: utilityNetwork,
                    featureTable: table,
                    attributes: feature.attributes
                )
            }
        } else if let geodatabaseFeatureTable = feature.table as? GeodatabaseFeatureTable,
                  let geodatabase = geodatabaseFeatureTable.geodatabase {
            try await geodatabase.load()
            
            let utilityNetworks = geodatabase.utilityNetworks
            await utilityNetworks.load()
            
            if let utilityNetwork = geodatabase.utilityNetworks.first(
                where: { $0.makeElement(arcGISFeature: feature) != nil }
            ) {
                print("🔹", "[geodatabase - element]", ObjectIdentifier(utilityNetwork))
                let element = utilityNetwork.makeElement(arcGISFeature: feature)!
                return try await .rules(for: utilityNetwork, assetType: element.assetType)
            } else if let utilityNetwork = utilityNetworks.first(where: { utilityNetwork in
                guard let definition = utilityNetwork.definition else { return false }
                return definition.networkSources.contains(
                    where: { $0.featureTable.tableName ==  table.tableName }
                )
            }) {
                print("🔹", "[geodatabase - table]", ObjectIdentifier(utilityNetwork))
                return try await .rules(
                    for: utilityNetwork,
                    featureTable: table,
                    attributes: feature.attributes
                )
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: - Bar Detent

/// A custom presentation detent that sizes to the approximate height of a top system toolbar.
private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        // Implementation was copied from:
        // https://developer.apple.com/documentation/swiftui/custompresentationdetent#overview
        return max(44, context.maxDetentValue * 0.1)
    }
}

private extension PresentationDetent {
    /// A custom presentation detent that sizes to the approximate height of a top system toolbar.
    static let bar = Self.custom(BarDetent.self)
}

// MARK: - Extensions

extension EnvironmentValues {
    /// An action to run before saving.
    @Entry var beforeSaveAction: (() -> Void)?
    
    /// A view to display in the bottom toolbar.
    @Entry var bottomToolbarContent: (any View)?
    
    /// A Boolean value indicating whether there are edits needing to be handled.
    @Entry var hasEdits = false
    
    /// Text describing a validation error.
    @Entry var validationErrorMessage: Text?
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

// TODO: Remove
func log(
    _ tag: String = "",
    file: NSString = #filePath,
    line: UInt = #line,
    function: StaticString = #function
) {
    print("\(tag) - \(file.lastPathComponent):\(line) \(function)")
}
