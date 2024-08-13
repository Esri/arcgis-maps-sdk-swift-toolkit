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
