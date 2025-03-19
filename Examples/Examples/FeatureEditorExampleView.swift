// Copyright 2023 Esri
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
import ArcGISToolkit
import SwiftUI

struct FeatureEditorExampleView: View {
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The presented feature form.
    @State private var featureForm: FeatureForm?
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
#warning("TO BE UNDONE. For UN testing only.")
    /// The `Map` displayed in the `MapView`.
    @State private var map = makeMap()
    //    @State private var map = Map(url: .sampleData)!
    
    let geometryEditor = GeometryEditor()
    
    /// The form view model provides a channel of communication between the form view and its host.
    //    @StateObject private var model = Model()
    
    @State var editedGeodatabase: ServiceGeodatabase?
    
    @State var editsViewIsPresented = false
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .geometryEditor(geometryEditor)
                .featureEditor(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .trailing,
                    isPresented: isPresented,
                    featureForm: $featureForm,
                    geometryEditor: geometryEditor
                ) {
                    FeatureEditorView(featureForm: $featureForm, geometryEditor: geometryEditor)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                            editsViewIsPresented = true
                        }
                        .disabled(editedGeodatabase == nil || !(editedGeodatabase!.hasLocalEdits))
                    }
                }
                .sheet(isPresented: $editsViewIsPresented) {
                    EditsView(serviceGeodatabase: editedGeodatabase!)
                }
                .task(id: identifyScreenPoint) {
                    print("geometryEditor: \(ObjectIdentifier(geometryEditor))")

                    if let feature = await identifyFeature(with: mapViewProxy) {
                        featureForm?.featureLayer?.clearSelection()
                        featureForm = FeatureForm(feature: feature)
                        featureForm?.featureLayer?.selectFeature(feature)
                        editedGeodatabase = (feature.table as? ServiceFeatureTable)?.serviceGeodatabase
                    }
                }
                .task {
#warning("TO BE REMOVED. Public credential is for UN testing only.")
                    do {
                        let publicSample = try await ArcGISCredential.publicSample
                        ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(publicSample)
                    } catch {
                        print("Error resolving credential: \(error.localizedDescription)")
                    }
                }
                .ignoresSafeArea(.keyboard)
        }
    }
    
#warning("TO BE REMOVED. FOR UNA DEVELOPMENT ONLY.")
    /// Makes a map from a portal item.
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID(rawValue: "471eb0bf37074b1fbb972b1da70fb310")!
        )
        return Map(item: portalItem)
    }
}

extension FeatureEditorExampleView {
    /// Identifies features, if any, at the current screen point.
    /// - Parameter proxy: The proxy to use for identification.
    /// - Returns: The first identified feature in a layer.
    func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
        guard let identifyScreenPoint else { return nil }
        let identifyLayerResults = try? await proxy.identifyLayers(
            screenPoint: identifyScreenPoint,
            tolerance: 10
        )
        return identifyLayerResults?.compactMap { result in
            result.geoElements.compactMap { element in
                element as? ArcGISFeature
            }.first
        }.first
    }
    
    /// A Boolean value indicating whether the form is presented.
    private var isPresented: Binding<Bool> {
        .init {
            featureForm != nil
        } set: { newValue in
            if !newValue {
                featureForm = nil
            }
        }
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}

#warning("TO BE REMOVED. FOR UNA DEVELOPMENT ONLY.")
private extension ArcGISCredential {
    static var publicSample: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                username: "viewer01",
                password: "I68VGU^nMurF"
            )
        }
    }
}

private extension FeatureForm {
    /// The layer to which the feature belongs.
    var featureLayer: FeatureLayer? {
        feature.table?.layer as? FeatureLayer
    }
}

private extension Array where Element == FeatureEditResult {
    ///  Any errors from the edit results and their inner attachment results.
    var errors: [Error] {
        compactMap(\.error) + flatMap { $0.attachmentResults.compactMap(\.error) }
    }
}

struct FeatureEditorView: View {
    enum EditorType {
        case none
        case geometry
        case attributes
    }
    
    private var featureForm: Binding<FeatureForm?>
    private var geometryEditor: GeometryEditor
    @State private var geometryChangedAlertIsPresented = false
    
    @State var geometryChange: GeometryChange?

    init(featureForm: Binding<FeatureForm?>, geometryEditor: GeometryEditor) {
        self.featureForm = featureForm
        self.geometryEditor = geometryEditor
    }

    var body: some View {
        VStack {
            FeatureFormView(featureForm: featureForm)
                .closeButton(.hidden) // Defaults to .automatic
                .onFormEditingEvent { action in
                    switch action {
                    case .discardedEdits(willNavigate: let willNavigate):
                        guard willNavigate else { return }
                        // navigation, just close out old feature, start new
                        print("should also discard geometry edits")
                        discard()
                    case .savedEdits(willNavigate: let willNavigate):
                        guard willNavigate else { return }
                        //                            featureForm.wrappedValue?.feature.geometry = geometry
                        print("should also save geometry edits")
                        save()
                        featureForm.wrappedValue?.feature.refresh()
                    }
                }
                .onAppear {
                    if let geometry = featureForm.wrappedValue?.feature.geometry {
                        geometryEditor.start(withInitial: geometry)
                    } else {
                        geometryEditor.start(withType: featureForm.wrappedValue?.feature.table?.geometryType ?? Point.self)
                    }
                }
                .alert(
                    "Geometry Changed",
                    isPresented: $geometryChangedAlertIsPresented,
                    actions: {
                        Button("Discard Edits", role: .destructive) {
                            //                                presentedForm.discardEdits()
                            //                                onFormEditingEventAction?(.discardedEdits(willNavigate: willNavigate))
                            //                                validationErrorVisibility = .hidden
                            //                                continuation()
                            // NO-OP - nothing to be done
                        }
                        Button("Save Edits") {
                            Task {
                                do {
                                    if let geometryChange {
                                        geometryChange.oldFeature.geometry = geometryChange.newGeometry
                                        try await (geometryChange.oldFeature.table as? ServiceFeatureTable)?.update(geometryChange.oldFeature)
                                        self.geometryChange = nil
                                    }
//                                    try await presentedForm.finishEditing()
//                                    onFormEditingEventAction?(.savedEdits(willNavigate: willNavigate))
//                                    continuation()
                                } catch {
#warning("Handle thrown errors.")
                                }
                            }
                        }
                    },
                    message: {
                            Text("You have unsaved geometry changes.")
                    }
                )
                .onChange(of: featureForm.wrappedValue) { oldValue, newValue in
//                    print("newFeatureForm: \(newValue?.title); oldValue: \(oldValue.wrappedValue?.title)")
                    // Clean up old featureForm info
                    if let oldValue {
                        (oldValue.feature.table?.layer as? FeatureLayer)?.unselectFeature(oldValue.feature)
                        if geometryEditor.isStarted,
                           let originalGeometry = oldValue.feature.geometry,
                           let newGeometry = geometryEditor.geometry {
                            if !GeometryEngine.isGeometry(originalGeometry, equivalentTo: newGeometry) {
                                geometryChange = GeometryChange(newGeometry: newGeometry, oldFeature: oldValue.feature, newFeature: newValue?.feature)
                                geometryChangedAlertIsPresented = true
                                print("Need to alert the user! There is a change to the original geometry.")
                            }
                        }
                        geometryEditor.stop()
                    }

                    if let newValue {
                        (newValue.feature.table?.layer as? FeatureLayer)?.selectFeature(newValue.feature)
                        if let geometry = newValue.feature.geometry {
                            geometryEditor.start(withInitial: geometry)
                        } else {
                            geometryEditor.start(withType: newValue.feature.table?.geometryType ?? Point.self)
                        }
                    }
                }
        }
    }
    
    private func discard() {
        geometryEditor.stop()
        (featureForm.wrappedValue?.feature.table?.layer as? FeatureLayer)?.clearSelection()
        // Should already be done by the FeatureForm
//        featureForm.wrappedValue?.discardEdits()
    }
    
    private func save() {
        Task {
            featureForm.wrappedValue?.feature.geometry = geometryEditor.stop()
            (featureForm.wrappedValue?.feature.table?.layer as? FeatureLayer)?.clearSelection()
            
            // Push the geometry changes to the local store
            try? await featureForm.wrappedValue?.finishEditing()
        }
    }
    
    struct GeometryChange: Equatable {
        var newGeometry: Geometry
        var oldFeature: Feature
        var newFeature: Feature?
        let id = UUID()
        
        static func == (lhs: FeatureEditorView.GeometryChange, rhs: FeatureEditorView.GeometryChange) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension FeatureForm: @retroactive Equatable {
    public static func == (lhs: FeatureForm, rhs: FeatureForm) -> Bool {
        lhs === rhs
    }
}

struct EditsView: View {
    let serviceGeodatabase: ServiceGeodatabase
    @State var syncingInProgress = false
    
    var body: some View {
        VStack {
            ZStack {
                Text("Local Edits")
                    .font(.title)
                    .padding()
                HStack {
                    Spacer()
                    Button("Clear Edits") {
                        Task {
                            try? await serviceGeodatabase.undoLocalEdits()
                        }
                    }
                    .padding()
                }
            }
            Divider()
            ForEach(serviceGeodatabase.connectedTables, id: \.tableName) { table in
                if table.hasLocalEdits {
                    Text("\(table.tableName) has local Edits")
                        .onAppear {
                            print("table.loadStatus: \(table.loadStatus)")
                        }
                }
            }
            Spacer()
            Divider()
            HStack {
                Button("ApplyEdits/Sync") {
                    Task {
                        syncingInProgress = true
                        do {
                            let results = try await serviceGeodatabase.applyEdits()
                            print("Sync results: \(results)")
                        } catch {
                            print("Sync error: \(error)")
                        }
                        syncingInProgress = false
                    }
                }
                .disabled(syncingInProgress)
                .padding(.trailing)
                if syncingInProgress {
                    ProgressView()
                }
            }
            .padding()
        }
    }
}
