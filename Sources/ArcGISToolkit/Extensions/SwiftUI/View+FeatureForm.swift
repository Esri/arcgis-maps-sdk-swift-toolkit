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
import SwiftUI

extension View {
    /// Modifier for watching ``FeatureForm.titleChanged`` events.
    /// - Parameters:
    ///   - featureForm: The feature form to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    func onTitleChange(
        of featureForm: FeatureForm,
        action: @escaping (_ newTitle: String) -> Void
    ) -> some View {
        return self
            .task(id: ObjectIdentifier(featureForm)) {
                for await title in featureForm.$title {
                    action(title)
                }
            }
    }
}
