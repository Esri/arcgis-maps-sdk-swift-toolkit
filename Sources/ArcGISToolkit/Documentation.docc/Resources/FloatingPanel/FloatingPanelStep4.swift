***REMOVED***
***REMOVED***Toolkit

struct FloatingPanelExampleView: View {
***REMOVED***@State private var selectedDetent: FloatingPanelDetent = .half
***REMOVED***
***REMOVED***@State private var isPresented = true
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
***REMOVED******REMOVED******REMOVED***.floatingPanel(selectedDetent: $selectedDetent, isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***List(1..<10) { number in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(number, format: .number)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
