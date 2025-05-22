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

extension FloatingPanelDetent {
    /// Use this preference to override the active FloatingPanelDetent.
    ///
    /// This can be used when a view shown in a Floating Panel needs to communicate that the view behind
    /// the Floating Panel should be revealed (e.g. to reveal a map for user interaction).
    ///
    /// When the Floating Panel can be re-expanded, set the preference to `nil`.
    struct Preference: PreferenceKey {
        static let defaultValue: FloatingPanelDetent? = nil
        
        static func reduce(value: inout FloatingPanelDetent?, nextValue: () -> FloatingPanelDetent?) {
            value = nextValue()
        }
    }
}
