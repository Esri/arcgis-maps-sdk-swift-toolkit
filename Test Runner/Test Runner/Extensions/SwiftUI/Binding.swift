// Copyright 2025 Esri
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

import SwiftUI

extension Binding where Value == Bool {
    /// Creates a Boolean binding that wraps a binding to an optional.
    ///
    /// `wrappedValue` is `true` when the given optional value is non-`nil`. The
    /// optional value is set to `nil` when the parent binding is set.
    /// - Parameter optionalValue: A binding to the optional value to wrap.
    init<T: Sendable>(optionalValue: Binding<T?>) {
        self.init {
            optionalValue.wrappedValue != nil
        } set: { _ in
            optionalValue.wrappedValue = nil
        }
    }
}
