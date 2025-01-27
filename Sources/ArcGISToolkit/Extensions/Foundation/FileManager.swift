***REMOVED*** Copyright 2025 Esri
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

import Foundation

extension FileManager {
***REMOVED******REMOVED***/ Calculates the size of a directory and all its contents.
***REMOVED******REMOVED***/ - Parameter url: The directory's URL.
***REMOVED******REMOVED***/ - Returns: The total size in bytes.
***REMOVED***func sizeOfDirectory(at url: URL) -> Int {
***REMOVED******REMOVED***guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 ***REMOVED***
***REMOVED******REMOVED***var totalSize = 0
***REMOVED******REMOVED***for case let fileURL as URL in enumerator {
***REMOVED******REMOVED******REMOVED***guard let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
***REMOVED******REMOVED******REMOVED******REMOVED***continue
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***totalSize += fileSize
***REMOVED***
***REMOVED******REMOVED***return totalSize
***REMOVED***
***REMOVED***
