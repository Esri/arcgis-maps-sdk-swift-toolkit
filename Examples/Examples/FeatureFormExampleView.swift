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
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The height to present the form at.
    @State private var detent: FloatingPanelDetent = .full
    
    /// The point on the screen the user tapped on to identify a feature.
    @State private var identifyScreenPoint: CGPoint?
    
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    /// The validation error visibility configuration of the form.
    @State private var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
    
    /// The form view model provides a channel of communication between the form view and its host.
    @StateObject private var model = Model()
    
    var body: some View {
        MapViewReader { mapViewProxy in
            MapView(map: map)
                .onAttributionBarHeightChanged {
                    attributionBarHeight = $0
                }
                .onSingleTapGesture { screenPoint, _ in
                    switch model.state {
                    case .idle:
                        identifyScreenPoint = screenPoint
                    case let .editing(featureForm):
                        model.state = .cancellationPending(featureForm)
                    default:
                        return
                    }
                }
                .task(id: identifyScreenPoint) {
                    if let feature = await identifyFeature(with: mapViewProxy),
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
                        model.state = .editing(FeatureForm(feature: feature, definition: formDefinition))
                    }
                }
                .ignoresSafeArea(.keyboard)
                .floatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    selectedDetent: $detent,
                    horizontalAlignment: .leading,
                    isPresented: model.formIsPresented
                ) {
                    if let featureForm = model.featureForm {
                        FeatureFormView(featureForm: featureForm)
                            .validationErrors(validationErrorVisibility)
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }
                }
                .onChange(of: model.formIsPresented.wrappedValue) { formIsPresented in
                    if !formIsPresented { validationErrorVisibility = .automatic }
                }
                .alert("Discard edits", isPresented: model.cancelConfirmationIsPresented) {
                    Button("Discard edits", role: .destructive) {
                        model.discardEdits()
                    }
                    if case let .cancellationPending(featureForm) = model.state {
                        Button("Continue editing", role: .cancel) {
                            model.state = .editing(featureForm)
                        }
                    }
                } message: {
                    Text("Updates to this feature will be lost.")
                }
                // swiftlint:disable vertical_parameter_alignment_on_call
                .alert(
                    "The form wasn't submitted",
                    isPresented: model.alertIsPresented
                ) { } message: {
                    if case let .generalError(_, errorMessage) = model.state {
                        errorMessage
                    }
                }
                // swiftlint:enable vertical_parameter_alignment_on_call
                .navigationBarBackButtonHidden(model.formIsPresented.wrappedValue)
                .overlay {
                    switch model.state {
                    case .validating, .finishingEdits, .applyingEdits:
                        HStack(spacing: 5) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            model.textForState
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    default:
                        EmptyView()
                    }
                }
                .sheet(isPresented: model.applyEditsErrorsArePresented) {
                    if case let .applyEditError(featureForm, errors) = model.state {
                        ErrorTable(errors: errors) {
                            model.state = .editing(featureForm)
                        }
                    }
                }
                .toolbar {
                    if model.formIsPresented.wrappedValue {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel", role: .cancel) {
                                guard case let .editing(featureForm) = model.state else { return }
                                model.state = .cancellationPending(featureForm)
                            }
                            .disabled(model.formControlsAreDisabled)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Submit") {
                                validationErrorVisibility = .visible
                                Task {
                                    await model.submitChanges()
                                }
                            }
                            .disabled(model.formControlsAreDisabled)
                        }
                    }
                }
        }
    }
}

extension FeatureFormExampleView {
    /// Identifies features, if any, at the current screen point.
    /// - Parameter proxy: The proxy to use for identification.
    /// - Returns: The first identified feature in a layer with
    /// a feature form definition.
    func identifyFeature(with proxy: MapViewProxy) async -> ArcGISFeature? {
        guard let identifyScreenPoint else { return nil }
        let identifyResult = try? await proxy.identifyLayers(
            screenPoint: identifyScreenPoint,
            tolerance: 10
        )
            .first(where: { result in
                if let feature = result.geoElements.first as? ArcGISFeature,
                   (feature.table?.layer as? FeatureLayer)?.featureFormDefinition != nil {
                    return true
                } else {
                    return false
                }
            })
        return identifyResult?.geoElements.first as? ArcGISFeature
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}

/// The model class for the form example view
@MainActor
class Model: ObservableObject {
    /// Feature form workflow states.
    enum State {
        /// No feature is being edited.
        case idle
        /// A feature form is in use.
        case editing(FeatureForm)
        /// The form is being checked for validation errors.
        case validating(FeatureForm)
        /// Edits are being committed to the local geodatabase.
        case finishingEdits(FeatureForm)
        /// Edits are being applied to the remote service.
        case applyingEdits(FeatureForm)
        
        /// The user has triggered potential cancellation.
        case cancellationPending(FeatureForm)
        /// There was an error in a workflow step.
        case generalError(FeatureForm, Text)
        /// There was an error applying edits to the remote service.
        case applyEditError(FeatureForm, [Error])
    }
    
    /// The current feature form workflow state.
    @Published var state: State = .idle {
        willSet {
            switch newValue {
            case let .editing(featureForm):
                featureForm.featureLayer?.selectFeature(featureForm.feature)
            case .idle:
                guard let featureForm else { return }
                featureForm.featureLayer?.unselectFeature(featureForm.feature)
            default:
                break
            }
        }
    }
    
    /// The current feature form, derived from ``Model/state-swift.property``.
    var featureForm: FeatureForm? {
        switch state {
        case .idle:
            return nil
        case
            let .editing(form), let .validating(form),
            let .finishingEdits(form), let .applyingEdits(form),
            let .cancellationPending(form), let .generalError(form, _), let .applyEditError(form, _):
            return form
        }
    }
    
    /// A Boolean value indicating whether external form controls like "Cancel" and "Submit" should be disabled.
    var formControlsAreDisabled: Bool {
        guard case .editing = state else { return true }
        return false
    }
    
    /// A Boolean value indicating whether any errors from applying edits are presented.
    var applyEditsErrorsArePresented: Binding<Bool> {
        Binding {
            guard case .applyEditError = self.state else { return false }
            return true
        } set: { newApplyEditsErrorsArePresented in
            if !newApplyEditsErrorsArePresented {
                guard case let .applyEditError(featureForm, array) = self.state else { return }
                self.state = .editing(featureForm)
            }
        }
    }
    
    /// A Boolean value indicating whether general form workflow errors are presented.
    var alertIsPresented: Binding<Bool> {
        Binding {
            guard case .generalError = self.state else { return false }
            return true
        } set: { newIsErrorShowing in
            if !newIsErrorShowing {
                guard case let .generalError(featureForm, _) = self.state else { return }
                self.state = .editing(featureForm)
            }
        }
    }
    
    /// A Boolean value indicating whether the alert confirming the user's intent to cancel is presented.
    var cancelConfirmationIsPresented: Binding<Bool> {
        Binding {
            guard case .cancellationPending = self.state else { return false }
            return true
        } set: { _ in
        }
    }
    
    /// A Boolean value indicating whether or not the form is displayed.
    var formIsPresented: Binding<Bool> {
        Binding {
            guard case .idle = self.state else { return true }
            return false
        } set: { _ in
        }
    }
    
    /// User facing text indicating the current form workflow state.
    ///
    /// This is most useful during post form processing to indicate ongoing background work.
    var textForState: Text {
        switch state {
        case .validating:
            Text("Validating")
        case .finishingEdits:
            Text("Finishing edits")
        case .applyingEdits:
            Text("Applying edits")
        default:
            Text("")
        }
    }
    
    /// Reverts any local edits that haven't yet been saved to service geodatabase.
    func discardEdits() {
        guard case let .cancellationPending(featureForm) = state else {
            return
        }
        featureForm.discardEdits()
        state = .idle
    }
    
    /// Submit the changes made to the form.
    func submitChanges() async {
        guard case let .editing(featureForm) = state else { return }
        await validateChanges(featureForm)
    }
    
    /// Checks the feature form for the presence of any validation errors.
    private func validateChanges(_ featureForm: FeatureForm) async {
        state = .validating(featureForm)
        guard featureForm.validationErrors.isEmpty else {
            state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
            return
        }
        await finishEdits(featureForm)
    }
    
    /// Commits feature edits to the local geodatabase.
    private func finishEdits(_ featureForm: FeatureForm) async {
        state = .finishingEdits(featureForm)
        guard let table = featureForm.feature.table as? ServiceFeatureTable else {
            state = .generalError(featureForm, Text("Error resolving feature table."))
            return
        }
        guard table.isEditable else {
            state = .generalError(featureForm, Text("The feature table isn't editable."))
            return
        }
        do {
            state = .finishingEdits(featureForm)
            try await table.update(featureForm.feature)
        } catch {
            state = .generalError(featureForm, Text("The feature update failed."))
            return
        }
        await applyEdits(featureForm, table)
    }
    
    /// Applies edits to the remote service.
    private func applyEdits(_ featureForm: FeatureForm, _ table: ServiceFeatureTable) async {
        state = .applyingEdits(featureForm)
        guard let database = table.serviceGeodatabase else {
            state = .generalError(featureForm, Text("No geodatabase found."))
            return
        }
        guard database.hasLocalEdits else {
            state = .generalError(featureForm, Text("No database edits found."))
            return
        }
        let resultErrors: [Error]
        do {
            if let serviceInfo = database.serviceInfo, serviceInfo.canUseServiceGeodatabaseApplyEdits {
                let featureTableEditResults = try await database.applyEdits()
                resultErrors = featureTableEditResults.flatMap { featureTableEditResult in
                    checkFeatureEditResults(featureForm, featureTableEditResult.editResults)
                }
            } else {
                let featureEditResults = try await table.applyEdits()
                resultErrors = checkFeatureEditResults(featureForm, featureEditResults)
            }
        } catch {
            state = .generalError(featureForm, Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"))
            return
        }
        if resultErrors.isEmpty {
            state = .idle
        } else {
            state = .applyEditError(featureForm, resultErrors)
        }
    }
    
    /// Examines all edit results for any errors.
    /// - Returns: Any errors encountered while applying edits.
    private func checkFeatureEditResults(_ featureForm: FeatureForm, _ featureEditResults: [FeatureEditResult]) -> [Error] {
        var errors = [Error]()
        featureEditResults.forEach { featureEditResult in
            if let editResultError = featureEditResult.error { errors.append(editResultError) }
            featureEditResult.attachmentResults.forEach { attachmentResult in
                if let error = attachmentResult.error {
                    errors.append(error)
                }
            }
        }
        return errors
    }
}

private extension FeatureForm {
    /// The layer to which the feature belongs.
    var featureLayer: FeatureLayer? {
        feature.table?.layer as? FeatureLayer
    }
}

/// A table to presented formatted errors.
struct ErrorTable: View {
    /// Wrapper for generic errors to enable identification.
    struct IdentifiableError: Identifiable {
        let id = UUID()
        let error: Error
    }
    
    /// Creates a table to presented formatted errors.
    /// - Parameters:
    ///   - errors: The errors to present.
    ///   - dismiss: The closure to perform when the table is dismissed.
    init(errors: [Error], dismiss: @escaping () -> Void) {
        self.errors = errors.compactMap { IdentifiableError(error: $0) }
        self.dismiss = dismiss
    }
    
    /// The errors to present.
    let errors: [IdentifiableError]
    
    /// The closure to perform when the table is dismissed.
    let dismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            Table(of: IdentifiableError.self) {
                TableColumn("Error") { error in
                    Text(String(describing: type(of: error.error)))
                }
                TableColumn("Code") { error in
                    if let serviceError = error.error as? ArcGIS.ServiceError {
                        Text(serviceError.code.description)
                    } else {
                        Text("-")
                    }
                }
                TableColumn("Details") { error in
                    if let serviceError = error.error as? ArcGIS.ServiceError {
                        Text(serviceError.details)
                            .lineLimit(nil)
                    } else {
                        Text(error.error.localizedDescription)
                            .lineLimit(nil)
                    }
                }
            } rows: {
                ForEach(errors) { identifiableError in
                    TableRow(identifiableError)
                }
            }
            .navigationTitle("Errors")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
