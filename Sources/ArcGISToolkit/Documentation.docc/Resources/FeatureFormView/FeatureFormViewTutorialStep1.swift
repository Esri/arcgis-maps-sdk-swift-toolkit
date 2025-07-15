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
        }
    }
}
