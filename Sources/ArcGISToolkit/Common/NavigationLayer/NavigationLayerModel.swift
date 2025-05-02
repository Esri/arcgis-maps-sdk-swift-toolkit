***REMOVED*** Copyright 2025 Esri
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

***REMOVED***

@Observable class NavigationLayerModel {
***REMOVED******REMOVED***/ An item representing a view pushed on the layer.
***REMOVED***struct Item {
***REMOVED******REMOVED******REMOVED***/ The closure which produces the view for the item.
***REMOVED******REMOVED***let view: () -> any View
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether another view is being pushed.
***REMOVED***private var isPushing = false
***REMOVED***
***REMOVED******REMOVED***/ The transition for the next time a view is appended or removed.
***REMOVED***private(set) var transition: AnyTransition = .push
***REMOVED***
***REMOVED******REMOVED***/ The set of views pushed on the layer.
***REMOVED***private(set) var views: [Item] = []
***REMOVED***
***REMOVED******REMOVED***/ The header background color for the current view.
***REMOVED***var headerBackgroundColor: Color? = nil
***REMOVED***
***REMOVED******REMOVED***/ The title for the current view.
***REMOVED***var title: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ The subtitle for the current view.
***REMOVED***var subtitle: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ The currently presented view (the last item).
***REMOVED***var presented: Item? {
***REMOVED******REMOVED***views.last
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Pop the current view.
***REMOVED***func pop() {
***REMOVED******REMOVED***guard !views.isEmpty else { return ***REMOVED***
***REMOVED******REMOVED***transition = .pop
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***_ = views.removeLast()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Push a view.
***REMOVED******REMOVED***/ - Parameter view: The view to push.
***REMOVED***func push(_ view: @escaping () -> any View) {
***REMOVED******REMOVED******REMOVED*** Prevent the same view from being pushed multiple times while the
***REMOVED******REMOVED******REMOVED*** animation is running.
***REMOVED******REMOVED***guard !isPushing else { return ***REMOVED***
***REMOVED******REMOVED***isPushing = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***transition = .push
***REMOVED******REMOVED***
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***views.append(.init(view: view))
***REMOVED*** completion: {
***REMOVED******REMOVED******REMOVED***self.isPushing = false
***REMOVED***
***REMOVED***
***REMOVED***
