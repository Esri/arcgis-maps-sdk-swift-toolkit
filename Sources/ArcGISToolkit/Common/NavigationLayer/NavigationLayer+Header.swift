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

extension NavigationLayer {
***REMOVED***struct Header: View {
***REMOVED******REMOVED******REMOVED***/ The model for the navigation layer.
***REMOVED******REMOVED***@Environment(NavigationLayerModel.self) private var model
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The height of the header content.
***REMOVED******REMOVED***@State private var height: CGFloat = .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The optional closure to perform when the back navigation button is pressed.
***REMOVED******REMOVED***let backNavigationAction: ((NavigationLayerModel) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The header trailing content.
***REMOVED******REMOVED***let headerTrailing: (() -> any View)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The width provided to the view.
***REMOVED******REMOVED***let width: CGFloat
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let backNavigationAction {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backNavigationAction(model)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.pop()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let label = Label("Back", systemImage: "chevron.left")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if backLabelIsVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(backButtonIsVisible ? 1 : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(!backButtonIsVisible, width: width / 6)
***REMOVED******REMOVED******REMOVED******REMOVED***if backButtonIsVisible && !backLabelIsVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: height)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let title = model.title, !title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: backButtonIsVisible ? .leading : .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.bold()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let subtitle = model.subtitle, !subtitle.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(subtitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onGeometryChange(for: CGFloat.self) { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***proxy.size.height
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** action: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***height = newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: (width / 6) * 4, alignment: backButtonIsVisible ? .leading : .center)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let headerTrailing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(headerTrailing())
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Keep the title and subtitle centered when no
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** trailing content is present.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: .zero, height: .zero)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: width / 6, alignment: .trailing)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(backButtonIsVisible || (model.title != nil && !model.title!.isEmpty) || headerTrailing != nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the back button is visible, *true* when there is at least one
***REMOVED******REMOVED******REMOVED***/ presented view and *false* otherwise.
***REMOVED******REMOVED***var backButtonIsVisible: Bool {
***REMOVED******REMOVED******REMOVED***model.presented != nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ A Boolean value indicating whether the back label is visible, *true* when the back button is
***REMOVED******REMOVED******REMOVED***/ visible and there is no title to show.
***REMOVED******REMOVED***var backLabelIsVisible: Bool {
***REMOVED******REMOVED******REMOVED***backButtonIsVisible && model.title == nil
***REMOVED***
***REMOVED***
***REMOVED***

fileprivate extension View {
***REMOVED******REMOVED***/ Optionally positions this view within an invisible frame with the specified size.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - applied: A Boolean condition indicating whether padding is applied.
***REMOVED******REMOVED***/   - width: A fixed width for the resulting view.
***REMOVED******REMOVED***/ - Returns: A view with a fixed width, if applied.
***REMOVED***@ViewBuilder
***REMOVED***func frame(_ applied: Bool, width: CGFloat) -> some View {
***REMOVED******REMOVED***if applied {
***REMOVED******REMOVED******REMOVED***self.frame(width: width, alignment: .leading)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Optionally adds an equal padding amount to specific edges of this view.
***REMOVED******REMOVED***/ - Parameter applied: A Boolean condition indicating whether padding is applied.
***REMOVED******REMOVED***/ - Returns: A view that’s padded, if applied.
***REMOVED***@ViewBuilder
***REMOVED***func padding(_ applied: Bool) -> some View {
***REMOVED******REMOVED***if applied {
***REMOVED******REMOVED******REMOVED***self.padding()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
