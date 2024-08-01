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

import Dispatch

extension MainActor {
***REMOVED******REMOVED***/ A version of `assumeIsolated` for use on iOS 16 with the Swift 5.9
***REMOVED******REMOVED***/ compiler.
***REMOVED******REMOVED***/ - Note: Remove when either the minimum version of Xcode is 15.3 (or
***REMOVED******REMOVED***/ newer) or the deployment target is iOS 17.
***REMOVED***@available(iOS, introduced: 16.0, obsoleted: 17.0)
***REMOVED***@_unavailableFromAsync
***REMOVED***static func runUnsafely<T>(
***REMOVED******REMOVED***_ body: @MainActor () throws -> T,
***REMOVED******REMOVED***file: StaticString = #fileID,
***REMOVED******REMOVED***line: UInt = #line
***REMOVED***) rethrows -> T {
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***return try MainActor.assumeIsolated(body, file: file, line: line)
***REMOVED*** else {
#if compiler(>=5.10)
***REMOVED******REMOVED******REMOVED***return try MainActor.assumeIsolated(body, file: file, line: line)
#else
***REMOVED******REMOVED******REMOVED******REMOVED*** https:***REMOVED***forums.swift.org/t/replacement-for-mainactor-unsafe/65956/2
***REMOVED******REMOVED******REMOVED***dispatchPrecondition(condition: .onQueue(.main))
***REMOVED******REMOVED******REMOVED***return try withoutActuallyEscaping(body) { fn in
***REMOVED******REMOVED******REMOVED******REMOVED***try unsafeBitCast(fn, to: (() throws -> T).self)()
***REMOVED******REMOVED***
#endif
***REMOVED***
***REMOVED***
***REMOVED***
