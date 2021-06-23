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

***REMOVED***/ Uses a Locator to provide search and suggest results. Most configuration should be done on the
***REMOVED***/ `GeocodeParameters` directly.
public protocol LocatorSearchSourceProtocol: SearchSourceProtocol {
***REMOVED******REMOVED***/ The locator used by this search source.
***REMOVED***var locator: LocatorTask { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for geocoding. Some properties on parameters will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***var geocodeParameters: GeocodeParameters { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Parameters used for getting suggestions. Some properties will be updated automatically
***REMOVED******REMOVED***/ based on searches.
***REMOVED***var suggestParameters: SuggestParameters { get ***REMOVED***
***REMOVED***
