struct FeatureFormViewExampleView: View {
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
                    await makeFeatureForm(point: identifyScreenPoint, map: mapView)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        submitButton
                    }
                }
        }
    }
}

extension FeatureFormViewExampleView {
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
    private func applyEdits() async {
        editsAreBeingApplied = true
        defer { editsAreBeingApplied = false }
        
        for table in editedTables {
            guard let database = table.serviceGeodatabase else {
                submissionError = .other("No geodatabase found.")
                return
            }
            guard database.hasLocalEdits else {
                submissionError = .other("No database edits found.")
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
                submissionError = .anyError(error)
                return
            }
            if !resultErrors.isEmpty {
                submissionError = .other("Apply edits returned ^[\(resultErrors.count) error](inflect: true).")
            }
            editedTables.removeAll { $0.tableName == table.tableName }
        }
    }
}
