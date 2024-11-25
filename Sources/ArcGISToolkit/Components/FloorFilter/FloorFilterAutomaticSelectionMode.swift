***REMOVED*** Copyright 2022 Esri
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

***REMOVED***/ Defines automatic selection behavior.
@available(visionOS, unavailable)
public enum FloorFilterAutomaticSelectionMode: Sendable {
***REMOVED******REMOVED***/ Always update selection based on the current viewpoint; clear the selection when the user
***REMOVED******REMOVED***/ navigates away.
***REMOVED***case always
***REMOVED******REMOVED***/ Only update the selection when there is a new site or facility in the current viewpoint;
***REMOVED******REMOVED***/ don't clear selection when the user navigates away.
***REMOVED***case alwaysNotClearing
***REMOVED******REMOVED***/ Never update selection based on the map or scene view's current viewpoint.
***REMOVED***case never
***REMOVED***
