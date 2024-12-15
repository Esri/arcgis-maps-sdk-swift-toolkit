import ArcGIS
import ArcGISToolkit
import SwiftUI

struct LocationButtonExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var locationDisplay = {
        let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
        locationDisplay.autoPanMode = .recenter
        locationDisplay.initialZoomScale = 40_000
        return locationDisplay
    }()
    
    var body: some View {
        MapView(map: map)
            .locationDisplay(locationDisplay)
            .overlay(alignment: .topTrailing) {
                LocationButton(locationDisplay: locationDisplay)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding()
            }
    }
}
