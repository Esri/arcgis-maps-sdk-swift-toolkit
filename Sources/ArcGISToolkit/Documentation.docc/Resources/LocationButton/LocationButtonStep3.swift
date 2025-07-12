import ArcGIS
import ArcGISToolkit
import SwiftUI

struct LocationButtonExampleView: View {
    @State private var map = Map(basemapStyle: .arcGISImagery)
    
    @State private var locationDisplay = {
        let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
        locationDisplay.initialZoomScale = 40_000
        return locationDisplay
    }()
    
    var body: some View {
        MapView(map: map)
            .locationDisplay(locationDisplay)
            .overlay(alignment: .topTrailing) {
                LocationButton(locationDisplay: locationDisplay)
                    .autoPanOptions([.recenter, .compassNavigation, .off])
                    .imageScale(.large)
                    .frame(minWidth: 50, minHeight: 50)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 8)
                    .padding()
            }
    }
}
