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
    
    var body: some View {
        MapViewReader { mapView in
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .sheet(isPresented: featureFormViewIsPresented) {
                    featureFormView
                }
                .task(id: identifyScreenPoint) {
                    guard !editsAreBeingApplied,
                          let identifyScreenPoint else { return }
                    await makeFeatureForm(point: identifyScreenPoint, mapView: mapView)
                }
        }
    }
}

extension FeatureFormExampleView {
    // MARK: Methods
    
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
        if let geoElements = identifyLayerResults?.first?.geoElements,
           let feature = geoElements.first as? ArcGISFeature {
            featureForm = FeatureForm(feature: feature)
        }
    }
    
    // MARK: Properties
    
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
}

private extension URL {
    static var sampleData: Self {
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}
