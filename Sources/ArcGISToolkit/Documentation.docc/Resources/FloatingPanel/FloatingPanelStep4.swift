import SwiftUI
import ArcGISToolkit

struct FloatingPanelExampleView: View {
    @State private var selectedDetent: FloatingPanelDetent = .half
    
    @State private var isPresented = true
    
    var body: some View {
        LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
            .floatingPanel(selectedDetent: $selectedDetent, isPresented: $isPresented) {
                List(1..<10) { number in
                    Text(number, format: .number)
                }
            }
    }
}
