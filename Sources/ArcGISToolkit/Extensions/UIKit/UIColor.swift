***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import UIKit

extension UIColor {
***REMOVED******REMOVED***/ The red, green, blue, and alpha components of the color.
***REMOVED***var rgba: (R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) {
***REMOVED******REMOVED***var r: CGFloat = 0
***REMOVED******REMOVED***var g: CGFloat = 0
***REMOVED******REMOVED***var b: CGFloat = 0
***REMOVED******REMOVED***var a: CGFloat = 0
***REMOVED******REMOVED***getRed(&r, green: &g, blue: &b, alpha: &a)
***REMOVED******REMOVED***return (r, g, b, a)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - otherColor: <#otherColor description#>
***REMOVED******REMOVED***/   - percent: <#percent description#>
***REMOVED******REMOVED***/ - Returns: <#description#>
***REMOVED***func interpolatedWith(_ otherColor: UIColor, at percent: CGFloat) -> UIColor? {
***REMOVED******REMOVED***let (r1, g1, b1, a1) = rgba
***REMOVED******REMOVED***let (r2, g2, b2, a2) = otherColor.rgba
***REMOVED******REMOVED***let c1 = 1.0 - percent
***REMOVED******REMOVED***return UIColor(
***REMOVED******REMOVED******REMOVED***red:   CGFloat(c1 * r1 + percent * r2),
***REMOVED******REMOVED******REMOVED***green: CGFloat(c1 * g1 + percent * g2),
***REMOVED******REMOVED******REMOVED***blue:  CGFloat(c1 * b1 + percent * b2),
***REMOVED******REMOVED******REMOVED***alpha: CGFloat(c1 * a1 + percent * a2)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
