***REMOVED***Toolkit
***REMOVED***

struct DocumentPickerExampleView: View {
***REMOVED***@State private var url: URL?
***REMOVED***
***REMOVED***@State private var isPresented: Bool = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if let url {
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.quickLookPreview($url)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Button("Import") {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.item]) { url in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.url = url
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
