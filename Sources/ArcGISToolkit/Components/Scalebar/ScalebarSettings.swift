***REMOVED*** Copyright 2022 Esri
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

***REMOVED***

***REMOVED***/ Customizes scalebar appearance and behavior.
@available(visionOS, unavailable)
public struct ScalebarSettings: Sendable {
***REMOVED******REMOVED***/ Determines if the scalebar should automatically hide/show itself.
***REMOVED***var autoHide: Bool
***REMOVED***
***REMOVED******REMOVED***/ The time to wait in seconds before the scalebar hides itself.
***REMOVED***var autoHideDelay: TimeInterval
***REMOVED***
***REMOVED******REMOVED***/ The corner radius used by bar style scalebar renders.
***REMOVED***var barCornerRadius: Double
***REMOVED***
***REMOVED******REMOVED***/ The darker fill color used by the alternating bar style render.
***REMOVED***var fillColor1: Color
***REMOVED***
***REMOVED******REMOVED***/ The lighter fill color used by the bar style renders.
***REMOVED***var fillColor2: Color
***REMOVED***
***REMOVED******REMOVED***/ The color of the prominent scalebar line.
***REMOVED***var lineColor: Color
***REMOVED***
***REMOVED******REMOVED***/ The shadow color used by all scalebar style renders.
***REMOVED***var shadowColor: Color
***REMOVED***
***REMOVED******REMOVED***/ The shadow radius used by all scalebar style renders.
***REMOVED***var shadowRadius: Double
***REMOVED***
***REMOVED******REMOVED***/ The text color used by all scalebar style renders.
***REMOVED***var textColor: Color
***REMOVED***
***REMOVED******REMOVED***/ The text shadow color used by all scalebar style renders.
***REMOVED***var textShadowColor: Color
***REMOVED***
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - autoHide: Determines if the scalebar should automatically hide/show itself.
***REMOVED******REMOVED***/   - autoHideDelay: The time to wait in seconds before the scalebar hides itself.
***REMOVED******REMOVED***/   - barCornerRadius: The corner radius used by bar style scalebar renders.
***REMOVED******REMOVED***/   - fillColor1: The darker fill color used by the alternating bar style render.
***REMOVED******REMOVED***/   - fillColor2: The lighter fill color used by the bar style renders.
***REMOVED******REMOVED***/   - lineColor: The color of the prominent scalebar line.
***REMOVED******REMOVED***/   - shadowColor: The shadow color used by all scalebar style renders.
***REMOVED******REMOVED***/   - shadowRadius: The shadow radius used by all scalebar style renders.
***REMOVED******REMOVED***/   - textColor: The text color used by all scalebar style renders.
***REMOVED******REMOVED***/   - textShadowColor: The text shadow color used by all scalebar style renders.
***REMOVED***public init(
***REMOVED******REMOVED***autoHide: Bool = false,
***REMOVED******REMOVED***autoHideDelay: TimeInterval = 1.75,
***REMOVED******REMOVED***barCornerRadius: Double = 2.5,
***REMOVED******REMOVED***fillColor1: Color = .black,
***REMOVED******REMOVED***fillColor2: Color = Color(uiColor: .lightGray).opacity(0.5),
***REMOVED******REMOVED***lineColor: Color = .white,
***REMOVED******REMOVED***shadowColor: Color = Color(uiColor: .black).opacity(0.65),
***REMOVED******REMOVED***shadowRadius: Double = 1.0,
***REMOVED******REMOVED***textColor: Color = .primary,
***REMOVED******REMOVED***textShadowColor: Color = .white
***REMOVED***) {
***REMOVED******REMOVED***self.autoHide = autoHide
***REMOVED******REMOVED***self.autoHideDelay = autoHideDelay
***REMOVED******REMOVED***self.barCornerRadius = barCornerRadius
***REMOVED******REMOVED***self.fillColor1 = fillColor1
***REMOVED******REMOVED***self.fillColor2 = fillColor2
***REMOVED******REMOVED***self.lineColor = lineColor
***REMOVED******REMOVED***self.shadowColor = shadowColor
***REMOVED******REMOVED***self.shadowRadius = shadowRadius
***REMOVED******REMOVED***self.textColor = textColor
***REMOVED******REMOVED***self.textShadowColor = textShadowColor
***REMOVED***
***REMOVED***

@available(visionOS, unavailable)
struct ScalebarSettingsKey: EnvironmentKey {
  static let defaultValue = ScalebarSettings()
***REMOVED***

@available(visionOS, unavailable)
extension EnvironmentValues {
***REMOVED***var scalebarSettings: ScalebarSettings {
***REMOVED******REMOVED***get { self[ScalebarSettingsKey.self] ***REMOVED***
***REMOVED******REMOVED***set { self[ScalebarSettingsKey.self] = newValue ***REMOVED***
***REMOVED***
***REMOVED***
