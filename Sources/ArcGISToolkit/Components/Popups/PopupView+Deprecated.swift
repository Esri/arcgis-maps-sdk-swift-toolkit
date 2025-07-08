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

import ArcGIS
import SwiftUI

public extension PopupView /* Deprecated */ {
    /// Specifies the visibility of the popup header.
    /// - Parameter visibility: The preferred visibility of the popup header.
    /// - Attention: Deprecated at 200.8.
    @available(*, deprecated, message: "Use 'init(root:isPresented:)' to control the close button visibility instead.")
    func header(_ visibility: Visibility) -> Self {
        return self
    }
    
    /// Specifies whether a "close" button should be shown to the right of the popup title. If the "close"
    /// button is shown, you should pass in the `isPresented` argument to the `PopupView`
    /// initializer, so that the the "close" button can close the view.
    /// Defaults to `false`.
    /// - Parameter newShowCloseButton: The new value.
    /// - Returns: A new `PopupView`.
    /// - Attention: Deprecated at 200.7.
    @available(*, deprecated, message: "Use 'init(root:isPresented:)' to control the close button visibility instead.")
    func showCloseButton(_ newShowCloseButton: Bool) -> Self {
        return self
    }
}
