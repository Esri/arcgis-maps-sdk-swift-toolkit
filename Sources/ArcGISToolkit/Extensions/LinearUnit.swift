***REMOVED*** Copyright 2023 Esri.

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

extension LinearUnit {
***REMOVED***var localizedAbbreviation: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .feet:
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "ft",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .module,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "An abbreviation of 'feet'."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .kilometers:
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "km",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .module,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "An abbreviation of 'kilometers'."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .meters:
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "m",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .module,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "An abbreviation of 'meters'."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .miles:
***REMOVED******REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "mi",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .module,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "An abbreviation of 'miles'."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED***
