import SwiftUI
import ArcGIS
import ArcGISToolkit

struct SearchExampleView: View {
    @State private var locatorSearchSource = SmartLocatorSearchSource(
        name: "My locator",
        maximumResults: 16,
        maximumSuggestions: 16
    )
    
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var searchResultsOverlay = GraphicsOverlay()
    
    @State private var searchResultViewpoint: Viewpoint? = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1000000
    )
    
    @State private var isGeoViewNavigating = false
    
    @State private var geoViewExtent: Envelope?
    
    @State private var queryArea: Geometry?
    
    @State private var queryCenter: Point?
}
