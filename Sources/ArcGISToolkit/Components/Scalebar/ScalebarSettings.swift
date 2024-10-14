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

import SwiftUI

/// Customizes scalebar appearance and behavior.
public struct ScalebarSettings: Sendable {
    /// Determines if the scalebar should automatically hide/show itself.
    var autoHide: Bool
    
    /// The time to wait in seconds before the scalebar hides itself.
    var autoHideDelay: TimeInterval
    
    /// The corner radius used by bar style scalebar renders.
    var barCornerRadius: Double
    
    /// The darker fill color used by the alternating bar style render.
    var fillColor1: Color
    
    /// The lighter fill color used by the bar style renders.
    var fillColor2: Color
    
    /// The color of the prominent scalebar line.
    var lineColor: Color
    
    /// The shadow color used by all scalebar style renders.
    var shadowColor: Color
    
    /// The shadow radius used by all scalebar style renders.
    var shadowRadius: Double
    
    /// The text color used by all scalebar style renders.
    var textColor: Color
    
    /// The text shadow color used by all scalebar style renders.
    var textShadowColor: Color
    
    /// - Parameters:
    ///   - autoHide: Determines if the scalebar should automatically hide/show itself.
    ///   - autoHideDelay: The time to wait in seconds before the scalebar hides itself.
    ///   - barCornerRadius: The corner radius used by bar style scalebar renders.
    ///   - fillColor1: The darker fill color used by the alternating bar style render.
    ///   - fillColor2: The lighter fill color used by the bar style renders.
    ///   - lineColor: The color of the prominent scalebar line.
    ///   - shadowColor: The shadow color used by all scalebar style renders.
    ///   - shadowRadius: The shadow radius used by all scalebar style renders.
    ///   - textColor: The text color used by all scalebar style renders.
    ///   - textShadowColor: The text shadow color used by all scalebar style renders.
    public init(
        autoHide: Bool = false,
        autoHideDelay: TimeInterval = 1.75,
        barCornerRadius: Double = 2.5,
        fillColor1: Color = .black,
        fillColor2: Color = Color(uiColor: .lightGray).opacity(0.5),
        lineColor: Color = .white,
        shadowColor: Color = Color(uiColor: .black).opacity(0.65),
        shadowRadius: Double = 1.0,
        textColor: Color = .primary,
        textShadowColor: Color = .white
    ) {
        self.autoHide = autoHide
        self.autoHideDelay = autoHideDelay
        self.barCornerRadius = barCornerRadius
        self.fillColor1 = fillColor1
        self.fillColor2 = fillColor2
        self.lineColor = lineColor
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.textColor = textColor
        self.textShadowColor = textShadowColor
    }
}

struct ScalebarSettingsKey: EnvironmentKey {
  static let defaultValue = ScalebarSettings()
}

extension EnvironmentValues {
    var scalebarSettings: ScalebarSettings {
        get { self[ScalebarSettingsKey.self] }
        set { self[ScalebarSettingsKey.self] = newValue }
    }
}
