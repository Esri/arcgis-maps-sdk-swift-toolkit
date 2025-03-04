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

class NavigationLayerModel: ObservableObject {
***REMOVED***struct Item {
***REMOVED******REMOVED***let title: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED***let subtitle: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED***let view: () -> any View
***REMOVED***
***REMOVED***
***REMOVED***@Published private(set) var transition: AnyTransition = .push
***REMOVED***
***REMOVED***@Published private(set) var views: [Item] = []
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@Published var footerContent: (() -> (any View))?
***REMOVED***
***REMOVED***var presented: Item? {
***REMOVED******REMOVED***views.last
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***push(.init(title: nil, subtitle: nil, view: view))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Push a view with a title.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - title: The title for the view.
***REMOVED******REMOVED***/   - view: The view to push.
***REMOVED***func push(title: String, _ view: @escaping () -> any View) {
***REMOVED******REMOVED***push(.init(title: title, subtitle: nil, view: view))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Push a view with a title and subtitle.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - title: The title for the view.
***REMOVED******REMOVED***/   - subtitle: The subtitle for the view.
***REMOVED******REMOVED***/   - view: The view to push.
***REMOVED***func push(title: String, subtitle: String, _ view: @escaping () -> any View) {
***REMOVED******REMOVED***push(.init(title: title, subtitle: subtitle, view: view))
***REMOVED***
***REMOVED***
***REMOVED***private func push(_ view: Item) {
***REMOVED******REMOVED***transition = .push
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***views.append(view)
***REMOVED***
***REMOVED***
***REMOVED***
