// Copyright 2023 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A type that can be used to make a view responsive to horizontal and vertical size classes.
///
/// Use the `CompactAware` protocol to easily detect compact environments in views. Simply add two
/// `@Environment` property wrappers for `.horizontalSizeClass` and `.verticalSizeClass` to
/// conforming views and use ``isCompact`` where needed.
public protocol CompactAware {
    var horizontalSizeClass: UserInterfaceSizeClass? { get }
    var verticalSizeClass: UserInterfaceSizeClass? { get }
}

extension CompactAware {
    /// A Boolean value indicating if the view is in a compact environment.
    ///
    /// - iPhone: `true` in vertical orientation and `false` otherwise.
    /// - iPad: `true` in multitasking mode at limited widths and `false` otherwise.
    /// - Mac Catalyst: Always `false`.
    public var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
}
