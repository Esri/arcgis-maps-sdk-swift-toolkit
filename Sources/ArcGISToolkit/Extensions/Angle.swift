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

extension Angle {
***REMOVED******REMOVED***/ This angle's degree value normalized between 0° and 360°.
***REMOVED***var normalized: Double {
***REMOVED******REMOVED***let normalized = self.degrees.truncatingRemainder(dividingBy: 360)
***REMOVED******REMOVED***if normalized < 0 {
***REMOVED******REMOVED******REMOVED***return normalized + 360
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return normalized
***REMOVED***
***REMOVED***
***REMOVED***
