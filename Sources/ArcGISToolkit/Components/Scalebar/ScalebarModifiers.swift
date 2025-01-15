***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ A modifier which "styles" a Text element's font, shadow color and radius.
struct ScalebarTextModifier: ViewModifier {
***REMOVED******REMOVED***/ Appearance settings.
***REMOVED***@Environment(\.scalebarSettings) var settings
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.font(Scalebar.font.font)
***REMOVED******REMOVED******REMOVED***.foregroundStyle(settings.textColor)
***REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED***color: settings.textShadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED***radius: settings.shadowRadius
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension Text {
***REMOVED***func scalebarText() -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***ScalebarTextModifier()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ A modifier which "styles" a scalebar's shadow color and radius.
struct ScalebarGroupShadowModifier: ViewModifier {
***REMOVED******REMOVED***/ Appearance settings.
***REMOVED***@Environment(\.scalebarSettings) var settings
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.compositingGroup()
***REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED***color: settings.shadowColor,
***REMOVED******REMOVED******REMOVED******REMOVED***radius: settings.shadowRadius
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
extension View {
***REMOVED***func scalebarShadow() -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***ScalebarGroupShadowModifier()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
