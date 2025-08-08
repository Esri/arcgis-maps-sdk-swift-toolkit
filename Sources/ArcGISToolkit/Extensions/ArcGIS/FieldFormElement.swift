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

extension FieldFormElement {
    /// The coded values of the element's domain.
    var codedValues: [CodedValue] {
        return (domain as? CodedValueDomain)?.codedValues ?? []
    }
    
    /// A Boolean value indicating whether the input is multiline or not.
    var isMultiline: Bool {
        input is TextAreaFormInput
    }
    
    /// Attempts to convert the value to a type suitable for the element's field type and then update
    /// the element with the converted value.
    func convertAndUpdateValue(_ value: String) {
        if fieldType == .text {
            updateValue(value)
        } else if let fieldType {
            if fieldType.isNumeric && value.isEmpty {
                updateValue(nil)
            } else if fieldType == .int16, let value = Int16(value) {
                updateValue(value)
            } else if fieldType == .int32, let value = Int32(value) {
                updateValue(value)
            } else if fieldType == .int64, let value = Int64(value) {
                updateValue(value)
            } else if fieldType == .float32, let value = Float32(value) {
                updateValue(value)
            } else if fieldType == .float64, let value = Float64(value) {
                updateValue(value)
            } else {
                updateValue(value)
            }
        }
    }
}
