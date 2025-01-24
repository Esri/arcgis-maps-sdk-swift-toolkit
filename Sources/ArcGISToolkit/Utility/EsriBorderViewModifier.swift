***REMOVED***
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

***REMOVED***/ A modifier which displays a 2 point width border and a shadow around a view.
struct EsriBorderViewModifier: ViewModifier {
***REMOVED***var padding: EdgeInsets
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***let roundedRect = RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.padding(padding)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***.background(.regularMaterial)
#else
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemBackground))
#endif
***REMOVED******REMOVED******REMOVED***.clipShape(roundedRect)
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***roundedRect
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(lineWidth: 2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(uiColor: .separator))
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED***color: .gray.opacity(0.4),
***REMOVED******REMOVED******REMOVED******REMOVED***radius: 3,
***REMOVED******REMOVED******REMOVED******REMOVED***x: 1,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 2
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

public extension View {
***REMOVED***func esriBorder(
***REMOVED******REMOVED***padding: EdgeInsets = .toolkitDefault
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(EsriBorderViewModifier(padding: padding))
***REMOVED***
***REMOVED***
