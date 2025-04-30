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

/// Applies the preference's default value in the case that a value for the preference was not already specified.
struct DefaultPreferenceModifier<K>: ViewModifier where K: PreferenceKey, K.Value: Equatable {
    @State private var value: K.Value?
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(K.self) { value in
                self.value = value
            }
            .preference(key: K.self, value: value ?? K.defaultValue)
    }
}

extension View {
    /// Confirms the default value for the given preference is set.
    func defaultPreference<K>(_: K.Type) -> some View where K: PreferenceKey, K.Value: Equatable {
        modifier(DefaultPreferenceModifier<K>())
    }
}
