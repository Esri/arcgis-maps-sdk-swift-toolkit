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

***REMOVED***/ A user presentable alert.
struct UtilityNetworkTraceUserAlert {
***REMOVED******REMOVED***/ Title of the alert.
***REMOVED***var title: String = String(
***REMOVED******REMOVED***localized: "Error",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A label in reference to an error that occurred during a utility network trace."
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ Description of the alert.
***REMOVED***var description: String
***REMOVED***
***REMOVED******REMOVED***/ An additional action to be taken on the alert.
***REMOVED***var button: Button<Text>?
***REMOVED***

extension UtilityNetworkTraceUserAlert {
***REMOVED***static var startingLocationNotDefined: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Please set at least 1 starting location.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var startingLocationsNotDefined: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Please set at least 2 starting locations.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var duplicateStartingPoint: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***title: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Failed to set starting point",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Duplicate starting points cannot be added.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var noTraceTypesFound: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "No trace types found.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var noUtilityNetworksFound: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "No utility networks found.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var unableToIdentifyElement: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***description: String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Element could not be identified.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A label indicating an element could not be identified as a starting point
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** for a utility network trace.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
