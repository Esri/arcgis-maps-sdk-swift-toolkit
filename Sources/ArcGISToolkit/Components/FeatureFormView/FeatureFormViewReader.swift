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

public struct FeatureFormViewReader<Content: View>: View {
***REMOVED******REMOVED***/ The view builder that creates the reader's content.
***REMOVED***public var content: (FeatureFormViewProxy) -> Content
***REMOVED***
***REMOVED******REMOVED***/ The proxy of this reader.
***REMOVED***@State private var proxy = FeatureFormViewProxy()
***REMOVED***
***REMOVED******REMOVED***/ Creates an instance that can perform programmatic actions of its
***REMOVED******REMOVED***/ child ``FeatureFormView``.
***REMOVED******REMOVED***/ - Parameter content: The reader's content, containing one map view. This
***REMOVED******REMOVED***/ view builder receives a ``FeatureFormViewProxy`` instance that you use to
***REMOVED******REMOVED***/ perform actions on the ``FeatureFormView``.
***REMOVED***public init(@ViewBuilder content: @escaping (FeatureFormViewProxy) -> Content) {
***REMOVED******REMOVED***self.content = content
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack { content(proxy) ***REMOVED***
***REMOVED******REMOVED******REMOVED***.onPreferenceChangeMain(PreferredFeatureFormViewKey.self) { featureFormView in
***REMOVED******REMOVED******REMOVED******REMOVED***proxy.featureFormView = featureFormView
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension FeatureFormView: @preconcurrency Equatable {
***REMOVED***public static func == (lhs: FeatureFormView, rhs: FeatureFormView) -> Bool {
***REMOVED******REMOVED***lhs.featureForm.feature == rhs.featureForm.feature
***REMOVED***
***REMOVED***

struct PreferredFeatureFormViewKey: PreferenceKey {
***REMOVED***static func reduce(value: inout FeatureFormView?, nextValue: () -> FeatureFormView?) {
***REMOVED******REMOVED***if value == nil, let nextValue = nextValue() {
***REMOVED******REMOVED******REMOVED***value = nextValue
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***nonisolated func onPreferenceChangeMain<K>(
***REMOVED******REMOVED***_ key: K.Type = K.self,
***REMOVED******REMOVED***perform action: @escaping @MainActor (K.Value) -> Void
***REMOVED***) -> some View where K: PreferenceKey, K.Value: Equatable & Sendable {
***REMOVED******REMOVED***return onPreferenceChange(key) { newValue in
***REMOVED******REMOVED******REMOVED***if Thread.isMainThread {
***REMOVED******REMOVED******REMOVED******REMOVED***MainActor.assumeIsolated {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(newValue)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***action(newValue)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
