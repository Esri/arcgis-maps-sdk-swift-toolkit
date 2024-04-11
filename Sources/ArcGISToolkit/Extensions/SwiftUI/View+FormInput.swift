// Copyright 2023 Esri
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
    /// Modifier for watching ``FormElement.isEditableChanged`` events.
    /// - Parameters:
    ///   - element: The form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    func onIsEditableChange(
        of element: FieldFormElement,
        action: @escaping (_ newIsEditable: Bool) -> Void
    ) -> some View {
        return self
            .task(id: ObjectIdentifier(element)) {
                for await isEditable in element.$isEditable {
                    action(isEditable)
                }
            }
    }
    
    /// Modifier for watching ``FormElement.isRequiredChanged`` events.
    /// - Parameters:
    ///   - element: The form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    func onIsRequiredChange(
        of element: FieldFormElement,
        action: @escaping (_ newIsRequired: Bool) -> Void
    ) -> some View {
        return self
            .task(id: ObjectIdentifier(element)) {
                for await isRequired in element.$isRequired {
                    action(isRequired)
                }
            }
    }
    
    /// Modifier for watching ``FormElement.valueChanged`` events.
    /// - Parameters:
    ///   - element: The form element to watch for changes on.
    ///   - action: The action which watches for changes.
    /// - Returns: The modified view.
    func onValueChange(
        of element: FieldFormElement,
        action: @escaping (_ newValue: Any?, _ newFormattedValue: String) -> Void
    ) -> some View {
        return self
            .task(id: ObjectIdentifier(element)) {
                for await value in element.$value {
                    action(value, element.formattedValue)
                }
            }
    }
}
