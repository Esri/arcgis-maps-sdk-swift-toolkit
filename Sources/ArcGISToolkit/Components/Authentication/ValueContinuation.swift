// Copyright 2022 Esri
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

import Foundation

/// An object that allows a consumer to await on a value and a provider to provide a value
/// asynchronously. This is effectively a continuation that holds a value.
@MainActor class ValueContinuation<Value: Sendable> {
    /// The value.
    private var _value: Value?
    
    /// A continuation if the resulting disposition is asked for before it is available.
    private var continuation: UnsafeContinuation<Value, Never>?
    
    /// Sets the value.
    /// - Parameter value: The value.
    func setValue(_ value: Value) {
        guard _value == nil else { return }
        _value = value
        continuation?.resume(returning: value)
    }
    
    /// The value. This property supports only one consumer.
    var value: Value {
        get async {
            guard _value == nil else {
                return _value!
            }
            precondition(continuation == nil)
            return await withUnsafeContinuation { continuation in
                self.continuation = continuation
            }
        }
    }
}
