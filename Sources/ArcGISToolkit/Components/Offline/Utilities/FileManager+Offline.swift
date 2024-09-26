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

import ArcGIS
import Foundation

extension FileManager {
    /// Calculates the size of a directory and all its contents.
    /// - Parameter url: The directory's URL.
    /// - Returns: The total size in bytes.
    func sizeOfDirectory(at url: URL) -> Int {
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        var accumulatedSize = 0
        for case let fileURL as URL in enumerator {
            guard let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                continue
            }
            accumulatedSize += size
        }
        return accumulatedSize
    }
}
