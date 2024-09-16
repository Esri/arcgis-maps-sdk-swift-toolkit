import ArcGISToolkit
import SwiftUI

struct DocumentPickerExampleView: View {
    @State private var url: URL?
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        if let url {
            ProgressView()
                .quickLookPreview($url)
        } else {
            Button("Import") {
                isPresented = true
            }
            .sheet(isPresented: $isPresented) {
                DocumentPickerView(contentTypes: [.item]) { url in
                    self.url = url
                    isPresented = false
                } onCancel: {
                }
            }
        }
    }
}
