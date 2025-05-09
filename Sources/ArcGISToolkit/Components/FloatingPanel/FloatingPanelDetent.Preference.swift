***REMOVED*** Copyright 2025 Esri
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

extension FloatingPanelDetent {
***REMOVED******REMOVED***/ Use this preference to override the active FloatingPanelDetent.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This can be used when a view shown in a Floating Panel needs to communicate that the view behind
***REMOVED******REMOVED***/ the Floating Panel should be revealed (e.g. to reveal a map for user interaction).
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ When the Floating Panel can be re-expanded, set the preference to `nil`.
***REMOVED***struct Preference: PreferenceKey {
***REMOVED******REMOVED***static let defaultValue: FloatingPanelDetent? = nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***static func reduce(value: inout FloatingPanelDetent?, nextValue: () -> FloatingPanelDetent?) {
***REMOVED******REMOVED******REMOVED***value = nextValue()
***REMOVED***
***REMOVED***
***REMOVED***
