***REMOVED*** Copyright 2024 Esri
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

struct XButton: View {
***REMOVED***enum Context {
***REMOVED******REMOVED******REMOVED***/ The button is used to clear content.
***REMOVED******REMOVED***case clear
***REMOVED******REMOVED******REMOVED***/ The button is used to dismiss content.
***REMOVED******REMOVED***case dismiss
***REMOVED***
***REMOVED***
***REMOVED***@Environment(\.dismiss) private var dismiss
***REMOVED***
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - context: The context the button is used in. Helps to provide an accurate accessibility title.
***REMOVED******REMOVED***/   - action: The button's action. Calls the DismissAction if no action is provided.
***REMOVED***init(_ context: Context, action: (() -> Void)? = nil) {
***REMOVED******REMOVED***self.action = action
***REMOVED******REMOVED***self.context = context
***REMOVED***
***REMOVED***
***REMOVED***let action: (() -> Void)?
***REMOVED***
***REMOVED***let context: Context
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button(title, systemImage: "xmark") {
***REMOVED******REMOVED******REMOVED***action?() ?? dismiss()
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED***._hoverEffectDisabled()
***REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED***.symbolRenderingMode(.hierarchical)
***REMOVED******REMOVED***.symbolVariant(.circle.fill)
***REMOVED***
***REMOVED***

extension XButton {
***REMOVED******REMOVED***/ The title for the button.
***REMOVED***var title: String {
***REMOVED******REMOVED***switch context {
***REMOVED******REMOVED***case .clear:
***REMOVED******REMOVED******REMOVED***String.clear
***REMOVED******REMOVED***case .dismiss:
***REMOVED******REMOVED******REMOVED***String.dismiss
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED***@ViewBuilder
***REMOVED***func _hoverEffectDisabled() -> some View {
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***self
***REMOVED******REMOVED******REMOVED******REMOVED***.hoverEffectDisabled()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self
***REMOVED***
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
#Preview {
***REMOVED***@Previewable @State var isPresented = true
***REMOVED***LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
***REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(verbatim: "Present")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***XButton(.dismiss)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationBackgroundInteraction(.disabled)
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED***
***REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED***
