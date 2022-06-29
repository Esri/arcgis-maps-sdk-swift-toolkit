***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ A view modifier that presents a sheet without waiting for a condition.
struct SheetViewModifier<SheetContent: View>: ViewModifier {
***REMOVED******REMOVED*** Even though we will present it right away we need to use a state variable for this.
***REMOVED******REMOVED*** Using a constant has 2 issues. One, it won't animate. Two, when challenging for multiple
***REMOVED******REMOVED*** endpoints at a time, and the challenges stack up, you can end up with a "already presenting"
***REMOVED******REMOVED*** error.
***REMOVED***@State private var isPresented = false
***REMOVED***var sheetContent: () -> SheetContent

***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED******REMOVED***.task { isPresented = true ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented, content: sheetContent)
***REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Presents a sheet without waiting for a condition.
***REMOVED***@ViewBuilder
***REMOVED***func sheet<Content: View>(content: @escaping () -> Content) -> some View {
***REMOVED******REMOVED***modifier(SheetViewModifier(sheetContent: content))
***REMOVED***
***REMOVED***
