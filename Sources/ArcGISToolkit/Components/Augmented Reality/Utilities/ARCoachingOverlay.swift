***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

#if !os(visionOS)
import ARKit
***REMOVED***

***REMOVED***/ A SwiftUI version of an ARCoachingOverlayView view.
struct ARCoachingOverlay {
***REMOVED******REMOVED***/ The closure to call when the coaching overlay view activates.
***REMOVED***private(set) var onCoachingOverlayActivateAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED******REMOVED***/ The closure to call when the coaching overlay view deactivates.
***REMOVED***private(set) var onCoachingOverlayDeactivateAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED******REMOVED***/ The closure to call when the user taps the coaching overlay view's Start Over button.
***REMOVED***private(set) var onCoachingOverlayRequestSessionResetAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The data source for an AR session.
***REMOVED***var sessionProvider: ARSessionProviding?
***REMOVED******REMOVED***/ The goal for the coaching overlay.
***REMOVED***var goal: ARCoachingOverlayView.Goal
***REMOVED******REMOVED***/ A Boolean value that indicates if coaching is in progress.
***REMOVED***var active: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Controls whether the coaching is in progress.
***REMOVED******REMOVED***/ - Parameter active: A Boolean value indicating if coaching is in progress.
***REMOVED******REMOVED***/ - Returns: The `ARCoachingOverlay`.
***REMOVED***func active(_ active: Bool) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.active = active
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when the coaching overlay view activates.
***REMOVED***func onCoachingOverlayActivate(
***REMOVED******REMOVED***perform action: @escaping (ARCoachingOverlayView) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCoachingOverlayActivateAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when the coaching experience is completely deactivated.
***REMOVED***func onCoachingOverlayDeactivate(
***REMOVED******REMOVED***perform action: @escaping (ARCoachingOverlayView) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCoachingOverlayDeactivateAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the closure to call when the user taps the coaching overlay view's Start Over button
***REMOVED******REMOVED***/ while the session is relocalizing.
***REMOVED***func onCoachingOverlayRequestSessionReset(
***REMOVED******REMOVED***perform action: @escaping (ARCoachingOverlayView) -> Void
***REMOVED***) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.onCoachingOverlayRequestSessionResetAction = action
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the AR session data source for the coaching overlay.
***REMOVED******REMOVED***/ - Parameter sessionProvider: The AR session data source.
***REMOVED******REMOVED***/ - Returns: The `ARCoachingOverlay`.
***REMOVED***func sessionProvider(_ sessionProvider: ARSessionProviding) -> Self {
***REMOVED******REMOVED***var view = self
***REMOVED******REMOVED***view.sessionProvider = sessionProvider
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***

extension ARCoachingOverlay: UIViewRepresentable {
***REMOVED***func makeUIView(context: Context) -> ARCoachingOverlayView {
***REMOVED******REMOVED***let view = ARCoachingOverlayView()
***REMOVED******REMOVED***view.delegate = context.coordinator
***REMOVED******REMOVED***view.activatesAutomatically = true
***REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***func updateUIView(_ uiView: ARCoachingOverlayView, context: Context) {
***REMOVED******REMOVED***uiView.sessionProvider = sessionProvider
***REMOVED******REMOVED***uiView.goal = goal
***REMOVED******REMOVED***uiView.setActive(active, animated: true)
***REMOVED******REMOVED***context.coordinator.onCoachingOverlayActivateAction = onCoachingOverlayActivateAction
***REMOVED******REMOVED***context.coordinator.onCoachingOverlayDeactivateAction = onCoachingOverlayDeactivateAction
***REMOVED******REMOVED***context.coordinator.onCoachingOverlayRequestSessionResetAction = onCoachingOverlayRequestSessionResetAction
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator()
***REMOVED***
***REMOVED***

extension ARCoachingOverlay {
***REMOVED***class Coordinator: NSObject, ARCoachingOverlayViewDelegate {
***REMOVED******REMOVED***var onCoachingOverlayActivateAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED******REMOVED***var onCoachingOverlayDeactivateAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED******REMOVED***var onCoachingOverlayRequestSessionResetAction: ((ARCoachingOverlayView) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
***REMOVED******REMOVED******REMOVED***onCoachingOverlayActivateAction?(coachingOverlayView)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
***REMOVED******REMOVED******REMOVED***onCoachingOverlayDeactivateAction?(coachingOverlayView)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
***REMOVED******REMOVED******REMOVED***onCoachingOverlayRequestSessionResetAction?(coachingOverlayView)
***REMOVED***
***REMOVED***
***REMOVED***
#endif
