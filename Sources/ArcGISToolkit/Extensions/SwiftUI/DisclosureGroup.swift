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

struct DisclosureGroupPadding: ViewModifier {
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
#if !targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED***.padding(.trailing, 2)
#endif
***REMOVED***
***REMOVED***

extension DisclosureGroup {
***REMOVED******REMOVED***/ Adds a marginal amount of trailing padding to the view to keep the right edge of the arrow from
***REMOVED******REMOVED***/ being clipped.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ On Mac Catalyst, DisclosureGroup arrows are on the left and do not have the clipping issue.
***REMOVED******REMOVED***/ - Bug: https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/issues/528
***REMOVED***func disclosureGroupPadding() -> some View {
***REMOVED******REMOVED***modifier(DisclosureGroupPadding())
***REMOVED***
***REMOVED***
