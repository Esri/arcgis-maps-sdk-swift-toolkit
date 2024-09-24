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

import Foundation

***REMOVED***/ An object that allows a consumer to await on a value and a provider to provide a value
***REMOVED***/ asynchronously. This is effectively a continuation that holds a value.
@MainActor class ValueContinuation<Value> {
***REMOVED******REMOVED***/ The value.
***REMOVED***private var _value: Value?
***REMOVED***
***REMOVED******REMOVED***/ A continuation if the resulting disposition is asked for before it is available.
***REMOVED***private var continuation: UnsafeContinuation<Value, Never>?
***REMOVED***
***REMOVED******REMOVED***/ Sets the value.
***REMOVED******REMOVED***/ - Parameter value: The value.
***REMOVED***func setValue(_ value: Value) {
***REMOVED******REMOVED***guard _value == nil else { return ***REMOVED***
***REMOVED******REMOVED***_value = value
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***continuation?.resume(returning: value)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The value. This property supports only one consumer.
***REMOVED***var value: Value {
***REMOVED******REMOVED***get async {
***REMOVED******REMOVED******REMOVED***guard _value == nil else {
***REMOVED******REMOVED******REMOVED******REMOVED***return _value!
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***precondition(continuation == nil)
***REMOVED******REMOVED******REMOVED***return await withUnsafeContinuation { continuation in
***REMOVED******REMOVED******REMOVED******REMOVED***self.continuation = continuation
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
