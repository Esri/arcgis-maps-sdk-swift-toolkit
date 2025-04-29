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
***REMOVED******REMOVED***@Environment(NavigationLayerModel.self) private var model
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var height: CGFloat = .zero
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The optional closure to perform when the back navigation button is pressed.
***REMOVED******REMOVED***let backNavigationAction: ((NavigationLayerModel) -> Void)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The header trailing content.
***REMOVED******REMOVED***let headerTrailing: (() -> any View)?
***REMOVED******REMOVED***
***REMOVED******REMOVED***let width: CGFloat
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack(alignment: .top) {
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let backNavigationAction {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backNavigationAction(model)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.pop()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let label = Label("Back", systemImage: "chevron.left")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if model.title == nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.titleAndIcon)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***label
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.opacity(showsBack ? 1 : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(!showsBack, width: width / 6)
***REMOVED******REMOVED******REMOVED******REMOVED***if showsBack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Divider()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(height: height)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !showsBack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let title = model.title, !title.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: showsBack ? .leading : .center) {
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
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: (width / 6) * 4, alignment: showsBack ? .leading : .center)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***if let headerTrailing {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(headerTrailing())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: width / 6, alignment: .trailing)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(showsBack || (model.title != nil && !model.title!.isEmpty))
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var showsBack: Bool {
***REMOVED******REMOVED******REMOVED***!model.views.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***

fileprivate extension View {
***REMOVED***@ViewBuilder
***REMOVED***func frame(_ applied: Bool, width: CGFloat) -> some View {
***REMOVED******REMOVED***if applied {
***REMOVED******REMOVED******REMOVED***self.frame(width: width, alignment: .leading)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Optionally adds an equal padding amount to specific edges of this view.
***REMOVED******REMOVED***/ - Parameter applied: A Boolean condition indicating whether padding is applied.
***REMOVED******REMOVED***/ - Returns: A view that’s padded if specified.
***REMOVED***@ViewBuilder
***REMOVED***func padding(_ applied: Bool) -> some View {
***REMOVED******REMOVED***if applied {
***REMOVED******REMOVED******REMOVED***self.padding()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***
