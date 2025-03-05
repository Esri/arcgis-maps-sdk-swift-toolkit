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
***REMOVED******REMOVED***/ The navigation footer.
***REMOVED***let footer: (() -> any View)?
***REMOVED***
***REMOVED******REMOVED***/ The root view.
***REMOVED***let root: () -> Content
***REMOVED***
***REMOVED***@StateObject private var model: NavigationLayerModel
***REMOVED***
***REMOVED***init(_ root: @escaping () -> Content) {
***REMOVED******REMOVED***self.root = root
***REMOVED******REMOVED***self.footer = nil
***REMOVED******REMOVED***_model = StateObject(wrappedValue: NavigationLayerModel())
***REMOVED***
***REMOVED***
***REMOVED***init(_ root: @escaping () -> Content, @ViewBuilder footer: (@escaping () -> any View)) {
***REMOVED******REMOVED***self.root = root
***REMOVED******REMOVED***self.footer = footer
***REMOVED******REMOVED***_model = StateObject(wrappedValue: NavigationLayerModel())
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { geometryProxy in
***REMOVED******REMOVED******REMOVED***VStack(spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***if model.views.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***root()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(model.transition)
***REMOVED******REMOVED******REMOVED*** else if let presented = model.presented?.view {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DestinationHeader()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(presented())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Re-trigger the transition animation when view count changes.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.id(model.views.count)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(model.transition)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if let footer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(footer())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom], isPortraitOrientation ? nil : .zero)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.overlay(Divider(), alignment: .top)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.transition(.move(edge: .bottom))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.environmentObject(model)
***REMOVED******REMOVED******REMOVED******REMOVED*** Apply container width so the animated transitions work correctly.
***REMOVED******REMOVED******REMOVED***.frame(width: geometryProxy.size.width)
***REMOVED***
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
#Preview {
***REMOVED***struct SampleList: View {
***REMOVED******REMOVED***@EnvironmentObject private var model: NavigationLayerModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Present a view") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.push { Text("View") ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Present a view with a title") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.push(title: "Title") { Text("View") ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Present a view with a title & subtitle") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.push(title: "Title", subtitle: "Subtitle") { Text("View") ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@Previewable @State var isPresented = true
***REMOVED***
***REMOVED***return LinearGradient(
***REMOVED******REMOVED***colors: [.red, .orange, .yellow],
***REMOVED******REMOVED***startPoint: .topLeading, endPoint: .bottomTrailing
***REMOVED***)
***REMOVED***.ignoresSafeArea(edges: .all)
***REMOVED***.floatingPanel(isPresented: $isPresented) {
***REMOVED******REMOVED***NavigationLayer {
***REMOVED******REMOVED******REMOVED***SampleList()
***REMOVED***
***REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED***
***REMOVED***
