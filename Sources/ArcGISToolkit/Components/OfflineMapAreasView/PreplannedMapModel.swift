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

***REMOVED***/ An object that encapsulates state about a preplanned map.
public class PreplannedMapModel: ObservableObject, Identifiable {
***REMOVED******REMOVED***/ The preplanned map area.
***REMOVED***let preplannedMapArea: PreplannedMapArea
***REMOVED***
***REMOVED******REMOVED***/ The result of the download job.
***REMOVED***@Published private(set) var result: Result<MobileMapPackage, Error>?
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***preplannedMapArea: PreplannedMapArea
***REMOVED***) {
***REMOVED******REMOVED***self.preplannedMapArea = preplannedMapArea
***REMOVED***
***REMOVED***
