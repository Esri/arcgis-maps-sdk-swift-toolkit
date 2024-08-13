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

import SwiftUI

public extension FeatureFormView {
    /// The visibility of the form title.
    enum TitleVisibility: Sendable {
        /// The form title is hidden.
        case hidden
        /// The form title is visible.
        case visible
    }
    
    /// Specifies the visibility of the form title.
    /// - Parameter visibility: The preferred visibility of the form title.
    /// - Since: 200.6
    func formTitle(_ visibility: TitleVisibility) -> FeatureFormView {
        var copy = self
        copy.titleVisibility = visibility
        return copy
    }
}
