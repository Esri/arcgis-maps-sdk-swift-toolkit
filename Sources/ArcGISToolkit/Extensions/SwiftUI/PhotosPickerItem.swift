// Copyright 2026 Esri
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

import _PhotosUI_SwiftUI

extension PhotosPickerItem {
    /// The original filename of the asset resource from when it was created or imported.
    ///
    /// This property requires a `NSPhotoLibraryUsageDescription` entry in the app's Info.plist.
    var originalFilename: String? {
        get async {
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard status == .authorized || status == .limited else { return nil }
            
            guard let itemIdentifier else { return nil }
            
            let result = PHAsset.fetchAssets(withLocalIdentifiers: [itemIdentifier], options: nil)
            guard let asset = result.firstObject else { return nil }
            
            let resources = PHAssetResource.assetResources(for: asset)
            return resources.first?.originalFilename
        }
    }
}
