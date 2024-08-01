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

/// A value that represents a height where a sheet naturally rests.
public enum FloatingPanelDetent: Equatable, Sendable {
    /// A height based upon a fraction of the maximum height.
    case fraction(_ fraction: CGFloat)
    /// The maximum height.
    case full
    /// Half of the maximum height.
    case half
    /// A height based upon a fixed value.
    case height(_ height: CGFloat)
    /// A height large enough to display a short summary.
    case summary
}
