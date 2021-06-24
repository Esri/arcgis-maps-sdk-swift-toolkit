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
***REMOVED***

***REMOVED***/ Extends `LocatorSearchSource` with intelligent search behaviors; adds support for features like
***REMOVED***/ type-specific placemarks, repeated search, and more. Advanced functionality requires knowledge of the
***REMOVED***/ underlying locator to be used well; this class implements behaviors that make assumptions about the
***REMOVED***/ locator being the world geocode service.
public class SmartLocatorSearchSource: LocatorSearchSource {
***REMOVED******REMOVED***/ The minimum number of results to attempt to return. If there are too few results, the search is
***REMOVED******REMOVED***/ repeated with loosened parameters until enough results are accumulated. If no search is
***REMOVED******REMOVED***/ successful, it is still possible to have a total number of results less than this threshold. Does not
***REMOVED******REMOVED***/ apply to repeated search with area constraint. Set to zero to disable search repeat behavior.
***REMOVED***var repeatSearchResultThreshold: Int = 1
***REMOVED***
***REMOVED******REMOVED***/ The minimum number of suggestions to attempt to return. If there are too few suggestions,
***REMOVED******REMOVED***/ request is repeated with loosened constraints until enough suggestions are accumulated.
***REMOVED******REMOVED***/ If no search is successful, it is still possible to have a total number of results less than this
***REMOVED******REMOVED***/ threshold. Does not apply to repeated search with area constraint. Set to zero to disable search
***REMOVED******REMOVED***/ repeat behavior.
***REMOVED***var repeatSuggestResultThreshold: Int = 6
***REMOVED***
***REMOVED******REMOVED***/ Web style used to find symbols for results. When set, symbols are found for results based on the
***REMOVED******REMOVED***/ result's `Type` field, if available. Defaults to the style identified by the name
***REMOVED******REMOVED***/ "Esri2DPointSymbolsStyle". The default Esri 2D point symbol has good results for many of the
***REMOVED******REMOVED***/ types returned by the world geocode service. You can use this property to customize result icons
***REMOVED******REMOVED***/ by publishing a web style, taking care to ensure that symbol keys match the `Type` attribute
***REMOVED******REMOVED***/ returned by the locator.
***REMOVED***var resultSymbolStyle: SymbolStyle?
***REMOVED***
***REMOVED******REMOVED******REMOVED***@State
***REMOVED******REMOVED******REMOVED***private var address: String = ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***@State
***REMOVED******REMOVED******REMOVED***private var result: Result<[GeocodeResult], Error> = .success([])
***REMOVED***
