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

struct NavigationLayerHeaderBackground: PreferenceKey {
    static let defaultValue: Color? = nil
    
    static func reduce(value: inout Color?, nextValue: () -> Color?) {
        value = nextValue()
    }
}

struct NavigationLayerTitle: PreferenceKey {
    static let defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

struct NavigationLayerSubtitle: PreferenceKey {
    static let defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

extension View {
    /// Sets a header background color for the navigation layer destination.
    /// - Parameter color: The color for the navigation layer destination.
    func navigationLayerHeaderBackground(_ color: Color) -> some View {
        preference(key: NavigationLayerHeaderBackground.self, value: color)
    }
    
    /// Sets a title for the navigation layer destination.
    /// - Parameters:
    ///   - title: The title for the navigation layer destination.
    func navigationLayerTitle(_ title: String) -> some View {
        preference(key: NavigationLayerTitle.self, value: title)
    }
    
    /// Sets a title and subtitle for the navigation layer destination.
    /// - Parameters:
    ///   - title: The title for the navigation layer destination.
    ///   - subtitle: The subtitle for the navigation layer destination.
    func navigationLayerTitle(_ title: String, subtitle: String) -> some View {
        preference(key: NavigationLayerTitle.self, value: title)
            .preference(key: NavigationLayerSubtitle.self, value: subtitle)
    }
}
