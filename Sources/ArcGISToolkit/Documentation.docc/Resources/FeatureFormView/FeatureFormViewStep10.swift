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
    
    @State private var map = makeMap()
    
    @StateObject private var model = Model()
    
    var body: some View {
        NavigationStack {
            MapViewReader { mapViewProxy in
                MapView(map: map)
            }
        }
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
    
    func submitChanges() async {
        guard case let .editing(featureForm) = state else { return }
        await validateChanges(featureForm)
    }
    
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
            state = .generalError(featureForm, Text("Changes were not applied."))
        }
    }
    
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
    
    private func validateChanges(_ featureForm: FeatureForm) async {
        state = .validating(featureForm)
        guard featureForm.validationErrors.isEmpty else {
            state = .generalError(featureForm, Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true)."))
            return
        }
        await finishEdits(featureForm)
    }
}

private extension FeatureForm {
    var featureLayer: FeatureLayer? {
        feature.table?.layer as? FeatureLayer
    }
}
