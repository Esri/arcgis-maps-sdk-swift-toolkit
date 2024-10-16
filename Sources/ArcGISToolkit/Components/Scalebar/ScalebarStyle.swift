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

***REMOVED***/ Visual scalebar styles.
public enum ScalebarStyle: Sendable {
***REMOVED******REMOVED***/ Displays a single unit with segmented bars of alternating fill color.
***REMOVED***case alternatingBar
***REMOVED***
***REMOVED******REMOVED***/ Displays a single unit.
***REMOVED***case bar
***REMOVED***
***REMOVED******REMOVED***/ Displays both metric and imperial units. The primary unit is displayed on top.
***REMOVED***case dualUnitLine
***REMOVED***
***REMOVED******REMOVED***/ Displays a single unit with tick marks.
***REMOVED***case graduatedLine
***REMOVED***
***REMOVED******REMOVED***/ Displays a single unit with endpoint tick marks.
***REMOVED***case line
***REMOVED***
