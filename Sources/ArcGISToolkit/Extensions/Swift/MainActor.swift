// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Dispatch

extension MainActor {
    /// A version of `assumeIsolated` for use on iOS 16 with the Swift 5.9
    /// compiler.
    /// - Note: Remove when either the minimum version of Xcode is 15.3 (or
    /// newer) or the deployment target is iOS 17.
    @available(iOS, introduced: 16.0, obsoleted: 17.0)
    @_unavailableFromAsync
    static func runUnsafely<T>(
        _ body: @MainActor () throws -> T,
        file: StaticString = #fileID,
        line: UInt = #line
    ) rethrows -> T {
        if #available(iOS 17.0, *) {
            return try MainActor.assumeIsolated(body, file: file, line: line)
        } else {
#if compiler(>=5.10)
            return try MainActor.assumeIsolated(body, file: file, line: line)
#else
            // https://forums.swift.org/t/replacement-for-mainactor-unsafe/65956/2
            dispatchPrecondition(condition: .onQueue(.main))
            return try withoutActuallyEscaping(body) { fn in
                try unsafeBitCast(fn, to: (() throws -> T).self)()
            }
#endif
        }
    }
}
