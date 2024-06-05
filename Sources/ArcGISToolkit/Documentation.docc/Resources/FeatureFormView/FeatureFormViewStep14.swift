import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FeatureFormExampleView: View {
    static func makeMap() -> Map {
        let portalItem = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: Item.ID("f72207ac170a40d8992b7a3507b44fad")!
        )
        return Map(item: portalItem)
    }
    
    @State private var detent: FloatingPanelDetent = .full
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var map = makeMap()
    
    @State private var validationErrorVisibility = FeatureFormView.ValidationErrorVisibility.automatic
    
    @StateObject private var model = Model()
    
    var body: some View {
        NavigationStack {
            MapViewReader { mapViewProxy in
                MapView(map: map)
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
            }
        }
    }
}

extension FeatureFormExampleView {
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

@MainActor
class Model: ObservableObject {
    enum State {
        case applyingEdits(FeatureForm)
        case cancellationPending(FeatureForm)
        case editing(FeatureForm)
        case finishingEdits(FeatureForm)
        case generalError(FeatureForm, Text)
        case idle
        case validating(FeatureForm)
    }
    
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
    
    var cancelConfirmationIsPresented: Binding<Bool> {
        Binding {
            guard case .cancellationPending = self.state else { return false }
            return true
        } set: { _ in
        }
    }
    
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
    
    var formControlsAreDisabled: Bool {
        guard case .editing = state else { return true }
        return false
    }
    
    var formIsPresented: Binding<Bool> {
        Binding {
            guard case .idle = self.state else { return true }
            return false
        } set: { _ in
        }
    }
    
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
    
    func discardEdits() {
        guard case let .cancellationPending(featureForm) = state else {
            return
        }
        featureForm.discardEdits()
        state = .idle
    }
    
    func submitEdits() async {
        guard case let .editing(featureForm) = state else { return }
        validateChanges(featureForm)
        
        guard case let .validating(featureForm) = state else { return }
        await finishEditing(featureForm)
        
        guard case let .finishingEdits(featureForm) = state else { return }
        await applyEdits(featureForm)
    }
    
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
                resultErrors = featureTableEditResults.flatMap { $0.editResults.errors }
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
    
    private func finishEditing(_ featureForm: FeatureForm) async {
        state = .finishingEdits(featureForm)
        do {
            try await featureForm.finishEditing()
        } catch {
            state = .generalError(featureForm, Text("Finish editing failed.\n\n\(error.localizedDescription)"))
        }
    }
    
    private func validateChanges(_ featureForm: FeatureForm) {
        state = .validating(featureForm)
        if !featureForm.validationErrors.isEmpty {
            state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
        }
    }
}

private extension FeatureForm {
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
