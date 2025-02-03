***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/ Provides a frame minimum height constraint, padding, background color and rounded corners for a
***REMOVED***/ form input.
struct FormInputStyle: ViewModifier {
***REMOVED***let isTappable: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***let cornerRadius: CGFloat = 10
***REMOVED******REMOVED***let content = content
***REMOVED******REMOVED******REMOVED***.frame(minHeight: 30)
***REMOVED******REMOVED******REMOVED***.padding(.horizontal, 10)
***REMOVED******REMOVED******REMOVED***.padding(.vertical, 5)
***REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .tertiarySystemFill))
***REMOVED******REMOVED******REMOVED***.cornerRadius(cornerRadius)
***REMOVED******REMOVED***if isTappable {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(.hoverEffect, .rect(cornerRadius: cornerRadius))
***REMOVED******REMOVED******REMOVED******REMOVED***.hoverEffect()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Provides a frame minimum height constraint, padding, background color and rounded corners
***REMOVED******REMOVED***/ for a form input.
***REMOVED***func formInputStyle(isTappable: Bool) -> some View {
***REMOVED******REMOVED***modifier(FormInputStyle(isTappable: isTappable))
***REMOVED***
***REMOVED***
