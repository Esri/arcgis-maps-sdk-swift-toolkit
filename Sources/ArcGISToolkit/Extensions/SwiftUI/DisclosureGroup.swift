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

struct DisclosureGroupPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
#if !targetEnvironment(macCatalyst)
            .padding(.trailing, 2)
#endif
    }
}

extension DisclosureGroup {
    /// Adds a marginal amount of trailing padding to the view to keep the right edge of the arrow from
    /// being clipped.
    ///
    /// On Mac Catalyst, DisclosureGroup arrows are on the left and do not have the clipping issue.
    /// - Bug: https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/issues/528
    func disclosureGroupPadding() -> some View {
        modifier(DisclosureGroupPadding())
    }
}
