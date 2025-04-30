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

***REMOVED***/ Applies the preference's default value in the case that a value for the preference was not already specified.
struct DefaultPreferenceModifier<K>: ViewModifier where K: PreferenceKey, K.Value: Equatable {
***REMOVED***@State private var value: K.Value?
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.onPreferenceChange(K.self) { value in
***REMOVED******REMOVED******REMOVED******REMOVED***self.value = value
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.preference(key: K.self, value: value ?? K.defaultValue)
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Confirms the default value for the given preference is set.
***REMOVED***func defaultPreference<K>(_: K.Type) -> some View where K: PreferenceKey, K.Value: Equatable {
***REMOVED******REMOVED***modifier(DefaultPreferenceModifier<K>())
***REMOVED***
***REMOVED***
