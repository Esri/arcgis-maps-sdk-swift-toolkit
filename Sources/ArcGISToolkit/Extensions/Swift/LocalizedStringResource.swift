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

import Foundation

extension LocalizedStringResource.BundleDescription {
    /// The toolkit's bundle.
    static let toolkit: Self = .atURL(Bundle.toolkitModule.bundleURL)
}


extension LocalizedStringResource {
    static var downloaded: Self {
        .init(
            "Downloaded",
            bundle: .toolkit,
            comment: "The status text when a map area is downloaded."
        )
    }
    
    static var downloadFailed: Self {
        .init(
            "Download failed",
            bundle: .toolkit,
            comment: "The status text when a map area failed to download."
        )
    }
    
    static var downloading: Self {
        .init(
            "Downloading",
            bundle: .toolkit,
            comment: "The status text when a map area is downloading."
        )
    }
    
    static var loading: Self {
        .init(
            "Loading",
            bundle: .toolkit,
            comment: "The status text when a map area is loading."
        )
    }
    
    static var loadingFailed: Self {
        .init(
            "Loading failed",
            bundle: .toolkit,
            comment: "The status text when a map area failed to load."
        )
    }
    
    static var noInternetConnectionErrorMessage: Self {
        .init(
            "No Internet Connection",
            bundle: .toolkit,
            comment: "An error message explaining that there is no internet connection."
        )
    }
}
