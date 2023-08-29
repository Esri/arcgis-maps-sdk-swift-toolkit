***REMOVED***
***REMOVED*** COPYRIGHT 1995-2022 ESRI
***REMOVED***
***REMOVED*** TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
***REMOVED*** Unpublished material - all rights reserved under the
***REMOVED*** Copyright Laws of the United States and applicable international
***REMOVED*** laws, treaties, and conventions.
***REMOVED***
***REMOVED*** For additional information, contact:
***REMOVED*** Environmental Systems Research Institute, Inc.
***REMOVED*** Attn: Contracts and Legal Services Department
***REMOVED*** 380 New York Street
***REMOVED*** Redlands, California, 92373
***REMOVED*** USA
***REMOVED***
***REMOVED*** email: contracts@esri.com
***REMOVED***

***REMOVED***

extension View {
***REMOVED******REMOVED***/ Adds an action to perform when this view detects data emitted by the
***REMOVED******REMOVED***/ given async sequence. If `action` is `nil`, then the async sequence is not observed.
***REMOVED******REMOVED***/ The `action` closure is captured the first time the view appears.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - sequence: The async sequence to observe.
***REMOVED******REMOVED***/   - action: The action to perform when a value is emitted by `sequence`.
***REMOVED******REMOVED***/   The value emitted by `sequence` is passed as a parameter to `action`.
***REMOVED******REMOVED***/   The `action` is called on the `MainActor`.
***REMOVED******REMOVED***/ - Returns: A view that triggers `action` when `sequence` emits a value.
***REMOVED***@MainActor @ViewBuilder func onReceive<S>(
***REMOVED******REMOVED***_ sequence: S,
***REMOVED******REMOVED***perform action: ((S.Element) -> Void)?
***REMOVED***) -> some View where S: AsyncSequence {
***REMOVED******REMOVED***if let action = action {
***REMOVED******REMOVED******REMOVED***task {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for try await element in sequence {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(element)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
