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
    /// An error message explaining that there is no internet connection.
    static var noInternetConnectionErrorMessage: Self {
        .init(
            "No Internet Connection",
            bundle: .toolkit,
            comment: "An error message explaining that there is no internet connection."
        )
    }
}
