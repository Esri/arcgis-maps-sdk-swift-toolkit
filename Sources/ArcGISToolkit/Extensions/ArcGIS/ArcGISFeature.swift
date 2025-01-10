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
import Foundation
import UIKit

extension ArcGISFeature {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Returns: <#description#>
***REMOVED***func makeSymbol() async -> UIImage? {
***REMOVED******REMOVED***if let featureLayer = table?.layer as? FeatureLayer,
***REMOVED******REMOVED***   let renderer = featureLayer.renderer,
***REMOVED******REMOVED***   let symbol = renderer.symbol(for: self) {
***REMOVED******REMOVED******REMOVED***let scale: CGFloat
#if os(visionOS)
***REMOVED******REMOVED******REMOVED***scale = 1
#else
***REMOVED******REMOVED******REMOVED***scale = await UIScreen.main.scale
#endif
***REMOVED******REMOVED******REMOVED***return try? await symbol.makeSwatch(scale: scale)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The global ID of the feature.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This property is `nil` if there is no global ID.
***REMOVED***var globalID: UUID? {
***REMOVED******REMOVED***if let id = attributes["globalid"] as? UUID {
***REMOVED******REMOVED******REMOVED***return id
***REMOVED*** else if let id = attributes["GLOBALID"] as? UUID {
***REMOVED******REMOVED******REMOVED***return id
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
