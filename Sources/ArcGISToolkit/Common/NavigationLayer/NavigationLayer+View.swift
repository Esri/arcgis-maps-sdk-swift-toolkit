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
