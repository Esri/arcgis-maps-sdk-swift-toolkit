***REMOVED***.

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

struct EsriBorderViewModifier: ViewModifier {
***REMOVED***var edgeInsets: EdgeInsets
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***let roundedRect = RoundedRectangle(cornerRadius: 8)
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.padding(edgeInsets)
***REMOVED******REMOVED******REMOVED***.background(Color(.systemBackground))
***REMOVED******REMOVED******REMOVED***.clipShape(roundedRect)
***REMOVED******REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED******REMOVED***roundedRect
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.stroke(lineWidth: 2)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(Color(.separator))
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.shadow(color: Color.gray.opacity(0.4),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 3,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: 1,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 2
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func esriBorder(
***REMOVED******REMOVED***edgeInsets: EdgeInsets = EdgeInsets(
***REMOVED******REMOVED******REMOVED***top: 8,
***REMOVED******REMOVED******REMOVED***leading: 12,
***REMOVED******REMOVED******REMOVED***bottom: 8,
***REMOVED******REMOVED******REMOVED***trailing: 12
***REMOVED******REMOVED***)
***REMOVED***) -> some View {
***REMOVED******REMOVED***return ModifiedContent(
***REMOVED******REMOVED******REMOVED***content: self,
***REMOVED******REMOVED******REMOVED***modifier: EsriBorderViewModifier(edgeInsets: edgeInsets)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
