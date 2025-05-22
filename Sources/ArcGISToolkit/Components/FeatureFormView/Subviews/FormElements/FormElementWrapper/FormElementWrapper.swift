***REMOVED*** Copyright 2024 Esri
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
***REMOVED***

***REMOVED***/ A view which wraps the creation of a view for the underlying field form element.
***REMOVED***/
***REMOVED***/ This view injects a header and footer. It also monitors whether a field form element is editable and
***REMOVED***/ chooses the correct input view based on the input type.
struct FormElementWrapper: View {
***REMOVED******REMOVED***/ The wrapped form element.
***REMOVED***let element: FormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***FormElementHeader(element: element)
***REMOVED******REMOVED******REMOVED***switch element {
***REMOVED******REMOVED******REMOVED***case let element as FieldFormElement:
***REMOVED******REMOVED******REMOVED******REMOVED***FieldFormElementView(element: element)
***REMOVED******REMOVED******REMOVED***case let element as UtilityAssociationsFormElement:
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationsFormElementView(element: element)
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***EmptyView()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***FormElementFooter(element: element)
***REMOVED***
***REMOVED***
***REMOVED***
