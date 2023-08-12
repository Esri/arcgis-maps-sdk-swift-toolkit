import SwiftUI
import ArcGISToolkit

struct FloatingPanelExampleView: View {
    @State private var selectedDetent: FloatingPanelDetent = .half
    
    @State private var isPresented = true
    
    var body: some View {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
    }
}
