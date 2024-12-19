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
***REMOVED***let assistedStyle: Bool
***REMOVED***
***REMOVED***@State private var colors: [Color] = [.red, .yellow, .green, .blue]
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.frame(minHeight: 30)
***REMOVED******REMOVED******REMOVED***.padding(.horizontal, 10)
***REMOVED******REMOVED******REMOVED***.padding(.vertical, 5)
***REMOVED******REMOVED******REMOVED***.background {
***REMOVED******REMOVED******REMOVED******REMOVED***if assistedStyle {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.blur(radius: 50)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation(.linear(duration: 5).repeatForever()) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***colors.shuffle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.allowsHitTesting(false)
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Color(uiColor: .tertiarySystemFill)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.cornerRadius(10)
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Provides a frame minimum height constraint, padding, background color and rounded corners
***REMOVED******REMOVED***/ for a form input.
***REMOVED***func formInputStyle(assistedStyle: Bool = false) -> some View {
***REMOVED******REMOVED***modifier(FormInputStyle(assistedStyle: assistedStyle))
***REMOVED***
***REMOVED***
