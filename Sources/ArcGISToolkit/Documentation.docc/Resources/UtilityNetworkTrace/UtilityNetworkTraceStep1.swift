import ArcGIS
import ArcGISToolkit
import SwiftUI

struct UtilityNetworkTraceExampleView: View {
    @State private var map = makeMap()
    
    @State var mapPoint: Point?
    
    @State var screenPoint: CGPoint?
    
    @State var resultGraphicsOverlay = GraphicsOverlay()
    
    @State var viewpoint: Viewpoint?
}
