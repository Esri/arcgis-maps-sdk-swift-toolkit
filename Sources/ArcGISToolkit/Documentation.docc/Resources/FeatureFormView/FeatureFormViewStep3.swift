***REMOVED***
***REMOVED***Toolkit
***REMOVED***

struct FeatureFormExampleView: View {
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let portalItem = PortalItem(
***REMOVED******REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED******REMOVED***id: Item.ID("f72207ac170a40d8992b7a3507b44fad")!
***REMOVED******REMOVED***)
***REMOVED******REMOVED***return Map(item: portalItem)
***REMOVED***
***REMOVED***
***REMOVED***@State private var map = makeMap()
***REMOVED***
***REMOVED***@StateObject private var model = Model()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***MapViewReader { mapViewProxy in
***REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: map)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

@MainActor
private class Model: ObservableObject {
***REMOVED***enum State {
***REMOVED******REMOVED***case applyingEdits(FeatureForm)
***REMOVED******REMOVED***case cancellationPending(FeatureForm)
***REMOVED******REMOVED***case editing(FeatureForm)
***REMOVED******REMOVED***case finishingEdits(FeatureForm)
***REMOVED******REMOVED***case generalError(FeatureForm, Text)
***REMOVED******REMOVED***case idle
***REMOVED******REMOVED***case validating(FeatureForm)
***REMOVED***
***REMOVED***

private extension FeatureForm {
***REMOVED***var featureLayer: FeatureLayer? {
***REMOVED******REMOVED***feature.table?.layer as? FeatureLayer
***REMOVED***
***REMOVED***
