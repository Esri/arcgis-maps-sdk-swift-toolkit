struct FeatureFormExampleView: View {
    /// The `Map` displayed in the `MapView`.
    @State private var map = Map(url: .sampleData)!
    
    var body: some View {
        MapViewReader { mapView in
            MapView(map: map)
        }
    }
}

private extension URL {
    static var sampleData: Self {
        .init(string: "https://www.arcgis.com/apps/mapviewer/index.html?webmap=f72207ac170a40d8992b7a3507b44fad")!
    }
}
