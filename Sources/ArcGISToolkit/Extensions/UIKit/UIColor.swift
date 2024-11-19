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

import UIKit

extension UIColor {
    /// The red, green, blue, and alpha components of the color.
    var rgba: (R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    /// Interpolates the color with `otherColor` at the provided `percent`.
    func interpolatedWith(_ otherColor: UIColor, at percent: CGFloat) -> UIColor? {
        let (r1, g1, b1, a1) = rgba
        let (r2, g2, b2, a2) = otherColor.rgba
        let c1 = 1.0 - percent
        return UIColor(
            red:   CGFloat(c1 * r1 + percent * r2),
            green: CGFloat(c1 * g1 + percent * g2),
            blue:  CGFloat(c1 * b1 + percent * b2),
            alpha: CGFloat(c1 * a1 + percent * a2)
        )
    }
}
