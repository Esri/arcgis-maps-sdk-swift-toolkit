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
    /// Tables with local edits that need to be applied.
    @State private var editedTables = [ServiceFeatureTable]()
    
    /// A Boolean value indicating whether edits are being applied.
    @State private var editsAreBeingApplied = false
    
    /// The presented feature form.
    @State private var featureForm: FeatureForm?
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The error to be presented in the alert.
    @State private var submissionError: SubmissionError?
    
    var body: some View {
        MapViewReader { mapView in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .alert(
                    isPresented: alertIsPresented,
                    error: submissionError,
                    actions: {}
                )
                .overlay {
                    submittingOverlay
                }
                .sheet(isPresented: featureFormViewIsPresented) {
                    featureFormView
                }
                .task(id: identifyScreenPoint) {
                    guard !editsAreBeingApplied,
                          let identifyScreenPoint else { return }
                    await makeFeatureForm(point: identifyScreenPoint, mapView: mapView)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        submitButton
                    }
                }
        }
    }
}

extension FeatureFormExampleView {
    /// An error encountered while submitting edits.
    enum SubmissionError: LocalizedError {
        case anyError(any Error)
        case other(String)
        
        var errorDescription: String? {
            switch self {
            case .anyError(let error):
                error.localizedDescription
            case .other(let message):
                message
            }
        }
    }
    
    // MARK: Methods
    
    /// Applies edits to the service feature table or geodatabase.
    private func applyEdits() async throws(SubmissionError) {
        editsAreBeingApplied = true
        defer { editsAreBeingApplied = false }
        
        for table in editedTables {
            guard let database = table.serviceGeodatabase else {
                throw .other("No geodatabase found.")
            }
            guard database.hasLocalEdits else {
                throw .other("No database edits found.")
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
                throw .anyError(error)
            }
            editedTables.removeAll { $0.tableName == table.tableName }
            if !resultErrors.isEmpty {
                throw .other(
                    "Apply edits returned ^[\(resultErrors.count) error](inflect: true)."
                )
            }
        }
    }
    
    /// Opens a form for the first feature found at the point on the map.
    /// - Parameters:
    ///   - point: The point to run identify at on the map view.
    ///   - mapView: The map view to identify on.
    private func makeFeatureForm(point: CGPoint, mapView: MapViewProxy) async {
        guard let identifyScreenPoint else { return }
        let identifyLayerResults = try? await mapView.identifyLayers(
            screenPoint: identifyScreenPoint,
            tolerance: 10
        )
        if let feature = identifyLayerResults?.compactMap({ result in
            result.geoElements.compactMap { element in
                element as? ArcGISFeature
            }.first
        }).first {
            featureForm = FeatureForm(feature: feature)
        }
    }
    
    // MARK: Properties
    
    /// A Boolean value indicating whether general form workflow errors are presented.
    private var alertIsPresented: Binding<Bool> {
        Binding {
            submissionError != nil
        } set: { newAlertIsPresented in
            if !newAlertIsPresented {
                submissionError = nil
            }
        }
    }
    
    /// The feature form view shown in the sheet over the map.
    private var featureFormView: some View {
        FeatureFormView(root: featureForm!, isPresented: featureFormViewIsPresented)
            .onFormEditingEvent { editingEvent in
                if case .savedEdits = editingEvent,
                   let table = featureForm?.feature.table as? ServiceFeatureTable,
                   !editedTables.contains(where: { $0 === table }) {
                    editedTables.append(table)
                }
            }
    }
    
    /// A Boolean value indicating whether the form is presented.
    private var featureFormViewIsPresented: Binding<Bool> {
        Binding {
            featureForm != nil
        } set: { newValue in
            if !newValue {
                featureForm = nil
            }
        }
    }
    
    /// The button used to apply edits made in forms.
    @ViewBuilder private var submitButton: some View {
        let databases = editedTables.compactMap(\.serviceGeodatabase)
        let localEditsExist = databases.contains(where: \.hasLocalEdits)
        if !featureFormViewIsPresented.wrappedValue, localEditsExist {
            Button("Submit") {
                Task {
                    do throws(SubmissionError) {
                        try await applyEdits()
                    } catch {
                        submissionError = error
                    }
                }
            }
            .disabled(editsAreBeingApplied)
        }
    }
    
    /// Overlay content that indicates the form is being submitted to the user.
    @ViewBuilder private var submittingOverlay: some View {
        if editsAreBeingApplied {
            ProgressView("Submitting")
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
        }
    }
}

private extension Array where Element == FeatureEditResult {
    ///  Any errors from the edit results and their inner attachment results.
    var errors: [Error] {
        compactMap(\.error) + flatMap { $0.attachmentResults.compactMap(\.error) }
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}
