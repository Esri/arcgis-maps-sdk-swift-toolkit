***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

import Foundation

public struct BasemapGalleryItem {
***REMOVED***public init(
***REMOVED******REMOVED***basemap: Basemap,
***REMOVED******REMOVED***name: String = "",
***REMOVED******REMOVED***description: String? = "",
***REMOVED******REMOVED***thumbnail: UIImage? = nil
***REMOVED***) {
***REMOVED******REMOVED***self.basemap = basemap
***REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED***self.thumbnail = thumbnail
***REMOVED***
***REMOVED***
***REMOVED***var basemap: Basemap
***REMOVED***var name: String
***REMOVED***var description: String?
***REMOVED***var thumbnail: UIImage?
***REMOVED***

***REMOVED***extension DisplayableBasemap: Identifiable {
***REMOVED******REMOVED***public var id: ObjectIdentifier { ObjectIdentifier(self) ***REMOVED***
***REMOVED******REMOVED***
