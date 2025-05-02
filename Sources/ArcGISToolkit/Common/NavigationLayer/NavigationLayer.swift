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

***REMOVED***/ Navigation designed to work for components hosted in Floating Panels.
***REMOVED***/
***REMOVED***/ As of iOS 18, nested Navigation Stacks aren't supported. Because we don't know how a developer has
***REMOVED***/ presented a Toolkit component, NavigationLayer provides a simple navigation implementation that can be
***REMOVED***/ used in a component presented either modally (e.g. a Sheet) or non-modally (a Floating Panel).
struct NavigationLayer<Content: View>: View {
***REMOVED***@Environment(\.isPortraitOrientation) var isPortraitOrientation
***REMOVED***
***REMOVED******REMOVED***/ The header trailing content.
***REMOVED***let headerTrailing: (() -> any View)?
***REMOVED***
***REMOVED******REMOVED***/ The footer content.
***REMOVED***let footer: (() -> any View)?
***REMOVED***
***REMOVED******REMOVED***/ The root view.
***REMOVED***let root: (NavigationLayerModel) -> Content
***REMOVED***
***REMOVED******REMOVED***/ The optional closure to perform when the back navigation button is pressed.
***REMOVED***var backNavigationAction: ((NavigationLayerModel) -> Void)? = nil
***REMOVED***
***REMOVED******REMOVED***/ The closure to perform when model's path changes.
***REMOVED***var onNavigationChangedAction: ((NavigationLayerModel.Item?) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ The model for the navigation layer.
***REMOVED***@State private var model = NavigationLayerModel()
***REMOVED***
***REMOVED***init(_ root: @escaping (NavigationLayerModel) -> Content) {
***REMOVED******REMOVED***self.headerTrailing = nil
***REMOVED******REMOVED***self.footer = nil
***REMOVED******REMOVED***self.root = root
***REMOVED***
***REMOVED***
***REMOVED***init(_ root: @escaping (NavigationLayerModel) -> Content, headerTrailing: (@escaping () -> any View)) {
***REMOVED******REMOVED***self.headerTrailing = headerTrailing
***REMOVED******REMOVED***self.footer = nil
***REMOVED******REMOVED***self.root = root
***REMOVED***
***REMOVED***
***REMOVED***init(_ root: @escaping (NavigationLayerModel) -> Content, footer: (@escaping () -> any View)) {
***REMOVED******REMOVED***self.headerTrailing = nil
***REMOVED******REMOVED***self.footer = footer
***REMOVED******REMOVED***self.root = root
***REMOVED***
***REMOVED***
***REMOVED***init(_ root: @escaping (NavigationLayerModel) -> Content, headerTrailing: (@escaping () -> any View), footer: (@escaping () -> any View)) {
***REMOVED******REMOVED***self.headerTrailing = headerTrailing
***REMOVED******REMOVED***self.footer = footer
***REMOVED******REMOVED***self.root = root
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***Header(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***backNavigationAction: backNavigationAction,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***headerTrailing: headerTrailing,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: geometryProxy.size.width
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***if model.views.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***root(model)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(model.transition)
***REMOVED******REMOVED******REMOVED*** else if let presented = model.presented?.view {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(presented())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset the title, subtitle and header background color
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** preference each time the presented view is changed to
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** avoid showing a stale value if no title or subtitle
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** was set.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.defaultPreference(NavigationLayerHeaderBackground.self)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.defaultPreference(NavigationLayerTitle.self)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.defaultPreference(NavigationLayerSubtitle.self)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Re-trigger the transition animation when view count changes.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.id(model.views.count)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(model.transition)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let footer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(footer())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], isPortraitOrientation ? nil : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(Divider(), alignment: .top)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .bottom))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.environment(model)
***REMOVED******REMOVED******REMOVED******REMOVED*** Apply container width so the animated transitions work correctly.
***REMOVED******REMOVED******REMOVED***.frame(width: geometryProxy.size.width)
***REMOVED******REMOVED******REMOVED***.onChange(of: model.views.count) {
***REMOVED******REMOVED******REMOVED******REMOVED***onNavigationChangedAction?(model.presented ?? nil)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onPreferenceChange(NavigationLayerHeaderBackground.self) { color in
***REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.model.headerBackgroundColor = color
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onPreferenceChange(NavigationLayerTitle.self) { title in
***REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.model.title = title
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onPreferenceChange(NavigationLayerSubtitle.self) { subtitle in
***REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.model.subtitle = subtitle
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

struct PreviewList: View {
***REMOVED***@Environment(NavigationLayerModel.self) private var model
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Button("Present a view") {
***REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "A view")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.containerRelativeFrame([.horizontal, .vertical])
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Present a view with a title") {
***REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "A view with navigationLayerTitle(_:) applied")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.containerRelativeFrame([.horizontal, .vertical])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle("Presented View's Title")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Present a view with a title and subtitle") {
***REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "A view with navigationLayerTitle(_:subtitle:) applied")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.containerRelativeFrame([.horizontal, .vertical])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Presented View's Title",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***subtitle: "Presented View's Subtitle"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.navigationLayerTitle("Navigation Layer", subtitle: "Root View")
***REMOVED***
***REMOVED***

#Preview("init(_:)") {
***REMOVED***NavigationLayer { _ in
***REMOVED******REMOVED***PreviewList()
***REMOVED***
***REMOVED***

#Preview("init(_:headerTrailing:)") {
***REMOVED***NavigationLayer { _ in
***REMOVED******REMOVED***PreviewList()
***REMOVED*** headerTrailing: {
***REMOVED******REMOVED***Button { ***REMOVED*** label: { Image(systemName: "xmark")  ***REMOVED***
***REMOVED***
***REMOVED***

#Preview("init(_:footer:)") {
***REMOVED***NavigationLayer { _ in
***REMOVED******REMOVED***PreviewList()
***REMOVED*** footer: {
***REMOVED******REMOVED***Text(verbatim: "Footer")
***REMOVED***
***REMOVED***

#Preview("init(_:headerTrailing:footer:)") {
***REMOVED***NavigationLayer { _ in
***REMOVED******REMOVED***PreviewList()
***REMOVED*** headerTrailing: {
***REMOVED******REMOVED***Button { ***REMOVED*** label: { Image(systemName: "xmark")  ***REMOVED***
***REMOVED*** footer: {
***REMOVED******REMOVED***Text(verbatim: "Footer")
***REMOVED***
***REMOVED***

#Preview("navigationLayerHeaderBackground(_:)") {
***REMOVED***@Previewable @Environment(\.colorScheme) var colorScheme
***REMOVED***
***REMOVED***NavigationLayer { model in
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Button("Present a list") {
***REMOVED******REMOVED******REMOVED******REMOVED***model.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "Destination")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerHeaderBackground(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Color(uiColor: colorScheme == .dark ? .systemBackground : .secondarySystemBackground)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension NavigationLayer {
***REMOVED******REMOVED***/ Sets a closure to perform when the back navigation button is pressed.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the back navigation button is pressed.
***REMOVED******REMOVED***/ - Note: Use this to interrupt reverse navigation (e.g. to warn a user of unsaved edits). The closure
***REMOVED******REMOVED***/ provides a reference to the navigation layer module which can be used to trigger the reverse
***REMOVED******REMOVED***/ navigation when ready.
***REMOVED***func backNavigationAction(perform action: @escaping (NavigationLayerModel) -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.backNavigationAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a closure to perform when the navigation layer's path changed.
***REMOVED******REMOVED***/ - Parameter action: The closure to perform when the navigation layer's path changed
***REMOVED******REMOVED***/ - Note: If no item is provided, the root view is presented..
***REMOVED***func onNavigationPathChanged(perform action: @escaping (NavigationLayerModel.Item?) -> Void) -> Self {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy.onNavigationChangedAction = action
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

struct NavigationLayerHeaderBackground: PreferenceKey {
***REMOVED***static let defaultValue: Color? = nil
***REMOVED***
***REMOVED***static func reduce(value: inout Color?, nextValue: () -> Color?) {
***REMOVED******REMOVED***value = nextValue()
***REMOVED***
***REMOVED***

struct NavigationLayerTitle: PreferenceKey {
***REMOVED***static let defaultValue: String? = nil
***REMOVED***
***REMOVED***static func reduce(value: inout String?, nextValue: () -> String?) {
***REMOVED******REMOVED***value = nextValue()
***REMOVED***
***REMOVED***

struct NavigationLayerSubtitle: PreferenceKey {
***REMOVED***static let defaultValue: String? = nil
***REMOVED***
***REMOVED***static func reduce(value: inout String?, nextValue: () -> String?) {
***REMOVED******REMOVED***value = nextValue()
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Sets a header background color for the navigation layer destination.
***REMOVED******REMOVED***/ - Parameter color: The color for the navigation layer destination.
***REMOVED***func navigationLayerHeaderBackground(_ color: Color) -> some View {
***REMOVED******REMOVED***preference(key: NavigationLayerHeaderBackground.self, value: color)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a title for the navigation layer destination.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - title: The title for the navigation layer destination.
***REMOVED***func navigationLayerTitle(_ title: String) -> some View {
***REMOVED******REMOVED***preference(key: NavigationLayerTitle.self, value: title)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets a title and subtitle for the navigation layer destination.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - title: The title for the navigation layer destination.
***REMOVED******REMOVED***/   - subtitle: The subtitle for the navigation layer destination.
***REMOVED***func navigationLayerTitle(_ title: String, subtitle: String) -> some View {
***REMOVED******REMOVED***preference(key: NavigationLayerTitle.self, value: title)
***REMOVED******REMOVED******REMOVED***.preference(key: NavigationLayerSubtitle.self, value: subtitle)
***REMOVED***
***REMOVED***
