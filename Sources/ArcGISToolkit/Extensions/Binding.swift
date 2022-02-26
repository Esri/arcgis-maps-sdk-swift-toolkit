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

extension Binding {
***REMOVED******REMOVED***/ Provides a way to listen for changes on bound parameters.
***REMOVED***func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
***REMOVED******REMOVED***Binding(
***REMOVED******REMOVED******REMOVED***get: { self.wrappedValue ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED***self.wrappedValue = newValue
***REMOVED******REMOVED******REMOVED******REMOVED***handler(newValue)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
