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
    
    @State private var cancelConfirmationIsPresented = false
    
    @State private var featureForm: FeatureForm? {
        didSet { featureFormIsPresented = featureForm != nil }
    }
    
    @State private var featureFormIsPresented = false
    
    @State private var floatingPanelDetent: FloatingPanelDetent = .full
    
    @State private var identifyScreenPoint: CGPoint?
    
    @State private var map = makeMap()
    
    @State private var submissionError: Text?
    
    var body: some View {
        MapViewReader { proxy in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint else { return }
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
                    
                    if let feature = identifyResult?.geoElements.first as? ArcGISFeature,
                       let formDefinition = (feature.table?.layer as? FeatureLayer)?.featureFormDefinition {
                        featureForm = FeatureForm(feature: feature, definition: formDefinition)
                    }
                }
                .floatingPanel(
                    selectedDetent: $floatingPanelDetent,
                    horizontalAlignment: .leading,
                    isPresented: $featureFormIsPresented
                ) {
                    if let featureForm {
                        FeatureFormView(featureForm: featureForm)
                            .padding([.horizontal])
                    }
                }
                .alert("Discard edits", isPresented: $cancelConfirmationIsPresented) {
                    Button("Discard edits", role: .destructive) {
                        featureForm?.discardEdits()
                        featureForm = nil
                    }
                    Button("Continue editing", role: .cancel) { }
                } message: {
                    Text("Updates to this feature will be lost.")
                }
                .alert(
                    "The form wasn't submitted",
                    isPresented: Binding(
                        get: { submissionError != nil },
                        set: { _ in submissionError = nil }
                    )
                ) { } message: {
                    if let submissionError {
                        submissionError
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if featureFormIsPresented {
                            Button("Cancel", role: .cancel) {
                                cancelConfirmationIsPresented = true
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if featureFormIsPresented {
                            Button("Submit") {
                                Task {
                                    await submitChanges()
                                }
                            }
                        }
                    }
                }
        }
    }
    
    /// Submit the changes made to the form.
    func submitChanges() async {
        guard let featureForm,
              let table = featureForm.feature.table as? ServiceFeatureTable,
              let database = table.serviceGeodatabase else {
            print("A precondition to submit the changes wasn't met.")
            return
        }
        
        guard table.isEditable else {
            submissionError = Text("The feature table isn't editable.")
            return
        }
        
        // Don't submit if there are validation errors.
        guard featureForm.validationErrors.isEmpty else {
            submissionError = Text("The form has ^[\(featureForm.validationErrors.count) validation error](inflect: true).")
            return
        }
        
        // Update the service feature table
        try? await table.update(featureForm.feature)
        
        guard database.hasLocalEdits else {
            print("No submittable changes found.")
            return
        }
        
        // Apply the changes.
        do {
            if let serviceInfo = database.serviceInfo,
               serviceInfo.canUseServiceGeodatabaseApplyEdits {
                _ = try await database.applyEdits()
            } else {
                _ = try await table.applyEdits()
            }
        } catch {
            submissionError = Text("The changes could not be applied to the database or table.\n\n\(error.localizedDescription)")
        }

        // Clear the feature form
        self.featureForm = nil
    }
}
