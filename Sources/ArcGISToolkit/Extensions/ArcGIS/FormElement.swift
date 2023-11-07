// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

extension FormElement: Equatable {
    public static func == (lhs: ArcGIS.FormElement, rhs: ArcGIS.FormElement) -> Bool {
        lhs === rhs
    }
}

extension FormElement: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
        hasher.combine(label)
    }
}

extension FormElement {
    /// The id of the element.
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
