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
                    if let feature = await identifyFeature(with: mapViewProxy) {
                        model.state = .editing(FeatureForm(feature: feature))
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
                .alert(
                    "The form wasn't submitted",
                    isPresented: model.alertIsPresented
                ) {
                    // No actions.
                } message: {
                    if case let .generalError(_, errorMessage) = model.state {
                        errorMessage
                    }
                }
                .navigationBarBackButtonHidden(model.formIsPresented.wrappedValue)
                .overlay {
                    switch model.state {
                    case .validating, .finishingEdits, .applyingEdits:
                        HStack(spacing: 5) {
                            ProgressView()
                                .progressViewStyle(.circular)
                            Text(model.state.label)
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                    default:
                        EmptyView()
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
                                    await model.submitEdits()
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
        /// Edits are being applied to the remote service.
        case applyingEdits(FeatureForm)
        /// The user has triggered potential cancellation.
        case cancellationPending(FeatureForm)
        /// A feature form is in use.
        case editing(FeatureForm)
        /// Edits are being committed to the local geodatabase.
        case finishingEdits(FeatureForm)
        /// There was an error in a workflow step.
        case generalError(FeatureForm, Text)
        /// No feature is being edited.
        case idle
        /// The form is being checked for validation errors.
        case validating(FeatureForm)
        
        /// User-friendly text that describes this state.
        var label: String {
            switch self {
            case .applyingEdits:
                "Applying Edits"
            case .cancellationPending:
                "Cancellation Pending"
            case .editing:
                "Editing"
            case .finishingEdits:
                "Finishing Edits"
            case .generalError:
                "Error"
            case .idle:
                ""
            case .validating:
                "Validating"
            }
        }
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
    
    // MARK: Properties
    
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
    
    /// The current feature form, derived from ``Model/state-swift.property``.
    var featureForm: FeatureForm? {
        switch state {
        case .idle:
            return nil
        case
            let .editing(form), let .validating(form),
            let .finishingEdits(form), let .applyingEdits(form),
            let .cancellationPending(form), let .generalError(form, _):
            return form
        }
    }
    
    /// A Boolean value indicating whether external form controls like "Cancel" and "Submit" should be disabled.
    var formControlsAreDisabled: Bool {
        guard case .editing = state else { return true }
        return false
    }
    
    /// A Boolean value indicating whether or not the form is displayed.
    var formIsPresented: Binding<Bool> {
        Binding {
            guard case .idle = self.state else { return true }
            return false
        } set: { _ in
        }
    }
    
    // MARK: Methods
    
    /// Reverts any local edits that haven't yet been saved to service geodatabase.
    func discardEdits() {
        guard case let .cancellationPending(featureForm) = state else {
            return
        }
        featureForm.discardEdits()
        state = .idle
    }
    
    /// Submit the changes made to the form.
    func submitEdits() async {
        guard case let .editing(featureForm) = state else { return }
        validateChanges(featureForm)
        
        guard case let .validating(featureForm) = state else { return }
        await finishEditing(featureForm)
        
        guard case let .finishingEdits(featureForm) = state else { return }
        await applyEdits(featureForm)
    }
    
    // MARK: Private methods
    
    /// Applies edits to the remote service.
    private func applyEdits(_ featureForm: FeatureForm) async {
        state = .applyingEdits(featureForm)
        guard let table = featureForm.feature.table as? ServiceFeatureTable else {
            state = .generalError(featureForm, Text("Error resolving feature table."))
            return
        }
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
                resultErrors = featureTableEditResults.flatMap(\.editResults.errors)
            } else {
                let featureEditResults = try await table.applyEdits()
                resultErrors = featureEditResults.errors
            }
        } catch {
            state = .generalError(featureForm, Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)"))
            return
        }
        if resultErrors.isEmpty {
            state = .idle
        } else {
            state = .generalError(featureForm, Text("Apply edits failed with ^[\(resultErrors.count) error](inflect: true)."))
        }
    }
    
    /// Commits feature edits to the local geodatabase.
    private func finishEditing(_ featureForm: FeatureForm) async {
        state = .finishingEdits(featureForm)
        do {
            try await featureForm.finishEditing()
        } catch {
            state = .generalError(featureForm, Text("Finish editing failed.\n\n\(error.localizedDescription)"))
        }
    }
    
    /// Checks the feature form for the presence of any validation errors.
    private func validateChanges(_ featureForm: FeatureForm) {
        state = .validating(featureForm)
        if !featureForm.validationErrors.isEmpty {
            state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
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
        compactMap { $0.error } + flatMap { $0.attachmentResults.compactMap { $0.error } }
    }
}
