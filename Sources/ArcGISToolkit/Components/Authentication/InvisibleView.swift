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

@MainActor
struct SheetViewModifier<SheetContent: View>: ViewModifier {
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
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***func sheet<Content: View>(content: @escaping () -> Content) -> some View {
***REMOVED******REMOVED***modifier(SheetViewModifier(sheetContent: content))
***REMOVED***
***REMOVED***
