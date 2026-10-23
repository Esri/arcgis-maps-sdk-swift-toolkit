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
    /// The active form as reported by the Feature Form View
    @State private var activeForm: FeatureForm?
    /// A Boolean value indicating whether general form workflow errors are presented.
    @State private var alertIsPresented = false
    /// Tables with local edits that need to be applied.
    @State private var editedTables = [ServiceFeatureTable]()
    /// A Boolean value indicating whether edits are being applied.
    @State private var editsAreBeingApplied = false
    /// A Boolean value indicating whether the form is presented.
    @State private var featureFormViewIsPresented = false
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    /// <#Description#>
    @State private var model = FeatureFormView.Model()!
    /// The error to be presented in the alert.
    @State private var submissionError: SubmissionError?
    
    var body: some View {
        MapViewReader { mapView in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .alert(isPresented: $alertIsPresented, error: submissionError) {
                    okButton
                }
                .overlay {
                    submittingOverlay
                }
                .inspector(isPresented: .constant(true)) {
                    List {
                        if let activeForm {
                            LabeledContent("Active Form") {
                                Text("\(activeForm.title) - \(activeForm.id)")
                            }
                        }
                        if model.formCount > 0 {
                            Section("^[\(model.formCount) Forms](inflect: true)") {
                                ForEach(model.ids, id: \.self) { featureID in
                                    if let form = model.form(for: featureID) {
                                        Menu("\(form.title) - \(form.id)") {
                                            Section("Geometry Status") {
                                                Button("Report Invalid", role: .destructive) {
                                                    model.setGeometryEditStatus(for: form.feature, status: .invalid)
                                                }
                                                Button("Report Valid") {
                                                    model.setGeometryEditStatus(for: form.feature, status: .valid)
                                                }
                                                Button("Clear") {
                                                    model.setGeometryEditStatus(for: form.feature, status: nil)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Picker("Save Button", selection: $model.saveButtonVisibility) {
                            Text("Automatic")
                                .tag(Visibility.automatic)
                            Text("Visible")
                                .tag(Visibility.visible)
                            Text("Hidden")
                                .tag(Visibility.hidden)
                        }
                        Picker("Validation Errors", selection: $model.validationErrorVisibility) {
                            Text("Automatic")
                                .tag(FeatureFormView.ValidationErrorVisibility.automatic)
                            Text("Visible")
                                .tag(FeatureFormView.ValidationErrorVisibility.visible)
                        }
                    }
                }
                .sheet(isPresented: $featureFormViewIsPresented) {
//                    model.reset()
                } content: {
                    featureFormView
                        .frame(idealWidth: 350)
                        .presentationBackgroundInteraction(.enabled(upThrough: .large))
                        .presentationDetents([.large, .medium])
                        .presentationSizing(.fitted)
                        .presentationPlacement()
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
            guard editedTables.contains(where: { $0 === table }) else {
                // Edits to this table were already batch-applied to the
                // geodatabase in a previous iteration.
                break
            }
            guard let database = table.serviceGeodatabase else {
                throw .other("No geodatabase found.")
            }
            guard database.hasLocalEdits else {
                throw .other("No database edits found.")
            }
            do {
                let makeSubmissionError: (_ errors: [Error]) -> SubmissionError = { errors in
                    .other("Apply edits returned ^[\(errors.count) error](inflect: true).")
                }
                if database.serviceInfo?.canUseServiceGeodatabaseApplyEdits ?? false {
                    let featureTableEditResults = try await database.applyEdits()
                    let resultErrors = featureTableEditResults.flatMap(\.editResults.errors)
                    guard resultErrors.isEmpty else {
                        throw makeSubmissionError(resultErrors)
                    }
                    editedTables.removeAll { $0.serviceGeodatabase === database }
                } else {
                    let featureEditResults = try await table.applyEdits()
                    let resultErrors = featureEditResults.errors
                    guard resultErrors.isEmpty else {
                        throw makeSubmissionError(resultErrors)
                    }
                    editedTables.removeAll { $0 === table }
                }
            } catch {
                throw .anyError(error)
            }
        }
    }
    
    /// Opens a form for the first feature found at the point on the map.
    /// - Parameters:
    ///   - point: The point to run identify at on the map view.
    ///   - mapView: The map view to identify on.
    private func makeFeatureForm(point: CGPoint, mapView: MapViewProxy) async {
        let identifyLayerResults = try? await mapView.identifyLayers(
            screenPoint: point,
            tolerance: 10
        )
        if let geoElements = identifyLayerResults?.first?.geoElements,
           let feature = geoElements.first as? ArcGISFeature {
            let newForm = FeatureForm(feature: feature)
            model.add(form: newForm)
            featureFormViewIsPresented = true
        }
    }
    
    // MARK: Properties
    
    /// The feature form view shown in the sheet over the map.
    private var featureFormView: some View {
        return FeatureFormView(model: model, isPresented: $featureFormViewIsPresented)
            .onFeatureFormChanged { form in
                activeForm = form
            }
            .onFormEditingEvent { _ in
//                if case .savedEdits = editingEvent,
//                   let table = featureForm.feature.table as? ServiceFeatureTable,
//                   !editedTables.contains(where: { $0 === table }) {
//                    editedTables.append(table)
//                }
            }
    }
    
    /// The button used to dismiss the submission error alert.
    private var okButton: some View {
        Button("OK") {
            alertIsPresented = false
            submissionError = nil
        }
    }
    
    /// The button used to apply edits made in forms.
    @ViewBuilder private var submitButton: some View {
        let databases = editedTables.compactMap(\.serviceGeodatabase)
        let localEditsExist = databases.contains(where: \.hasLocalEdits)
        if !$featureFormViewIsPresented.wrappedValue, localEditsExist {
            Button("Submit") {
                Task {
                    do throws(SubmissionError) {
                        try await applyEdits()
                    } catch {
                        alertIsPresented = true
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

private extension View {
    @ViewBuilder
    func presentationPlacement() -> some View {
        if #available(iOS 27.0, *) {
            self.presentationPlacement(.leading)
        } else {
            self
        }
    }
}

private extension FeatureForm {
    var id: String {
        var oid = String(describing: ObjectIdentifier(self))
        oid.removeLast()
        return String(oid.suffix(4))
    }
}
