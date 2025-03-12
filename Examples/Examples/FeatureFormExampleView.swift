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

struct FeatureFormExampleView: View {
    /// The error to be presented in the alert.
    @State private var alertError: String?
    
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// Tables with local edits that need to be applied.
    @State private var editedTables = [ServiceFeatureTable]()
    
    /// The presented feature form.
    @State private var featureForm: FeatureForm?
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// A Boolean value indicating whether edits are being applied.
    @State private var isApplyingEdits = false
    
    /// The visibility of the submit button.
    @State private var submitButtonVisibility = Visibility.hidden
    
#warning("TO BE UNDONE. For UN testing only.")
    /// The `Map` displayed in the `MapView`.
    @State private var map = makeMap()
//    @State private var map = Map(url: .sampleData)!
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy) {
                        featureForm = FeatureForm(feature: feature)
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
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .leading,
                    isPresented: featureFormViewIsPresented
                ) {
                    FeatureFormView(featureForm: $featureForm)
                        .closeButton(.visible) // Defaults to .automatic
                        .onFormEditingEvent { editingEvent in
                            if case .savedEdits = editingEvent,
                               let table = featureForm?.feature.table as? ServiceFeatureTable,
                               !editedTables.contains(where: { $0.tableName == table.tableName }) {
                                editedTables.append(table)
                                updateSubmitButtonVisibility()
                            }
                        }
                }
                .alert("Error", isPresented: alertIsPresented) {
                } message: {
                    if let error = alertError {
                        Text(error)
                    }
                }
                .overlay {
                    if isApplyingEdits {
                        HStack(spacing: 5) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text("Applying edits")
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                    } else {
                        EmptyView()
                    }
                }
                .toolbar {
                    if submitButtonVisibility != .hidden {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Submit") {
                                Task {
                                    await applyEdits()
                                }
                            }
                        }
                    }
                }
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

extension FeatureFormExampleView {
    // MARK: Methods
    
    /// Applies edits to the remote service.
    private func applyEdits() async {
        isApplyingEdits = true
        defer {
            isApplyingEdits = false
            updateSubmitButtonVisibility()
        }
        
        for table in editedTables {
            guard let database = table.serviceGeodatabase else {
                alertError = "No geodatabase found."
                return
            }
            guard database.hasLocalEdits else {
                alertError = "No database edits found."
                return
            }
            let resultErrors: [Error]
            do {
                if let serviceInfo = database.serviceInfo, serviceInfo.canUseServiceGeodatabaseApplyEdits {
                    let featureTableEditResults = try await database.applyEdits()
                    resultErrors = featureTableEditResults.flatMap(\.editResults.errors)
                } else {
                    let featureEditResults = try await table.applyEdits()
                    resultErrors = featureEditResults.errors
                }
            } catch {
                alertError = "The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"
                return
            }
            if !resultErrors.isEmpty {
                alertError = "Apply edits failed with ^[\(resultErrors.count) error](inflect: true)."
            }
            editedTables.removeAll { $0.tableName == table.tableName }
        }
    }
    
    /// Identifies features, if any, at the current screen point.
    /// - Parameter proxy: The proxy to use for identification.
    /// - Returns: The first identified feature in a layer.
    private func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
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
    
    private func updateSubmitButtonVisibility() {
        guard featureForm == nil || !(featureForm?.hasEdits ?? false) else {
            submitButtonVisibility = .hidden
            return
        }
        let databases = editedTables.compactMap { $0.serviceGeodatabase }
        if databases.contains(where: \.hasLocalEdits) {
            submitButtonVisibility = .visible
        } else {
            submitButtonVisibility = .hidden
        }
    }
    
    // MARK: Properties
    
    /// A Boolean value indicating whether general form workflow errors are presented.
    private var alertIsPresented: Binding<Bool> {
        Binding {
            self.alertError != nil
        } set: { newAlertIsPresented in
            if !newAlertIsPresented {
                self.alertError = nil
            }
        }
    }
    
    /// A Boolean value indicating whether the form is presented.
    private var featureFormViewIsPresented: Binding<Bool> {
        .init {
            featureForm != nil
        } set: { newValue in
            if !newValue {
                featureForm = nil
            }
        }
    }
}

extension ArcGISFeature {
    var globalID: UUID? {
        if let id = attributes["globalid"] as? UUID {
            return id
        } else if let id = attributes["GLOBALID"] as? UUID {
            return id
        } else {
            return nil
        }
    }
}

extension ArcGISFeature: @retroactive Equatable {
    public static func == (lhs: ArcGIS.ArcGISFeature, rhs: ArcGIS.ArcGISFeature) -> Bool {
        lhs.globalID == rhs.globalID
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
