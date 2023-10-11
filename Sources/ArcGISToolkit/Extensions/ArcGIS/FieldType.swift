// Copyright 2023 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS

extension FieldType {
    /// A Boolean value indicating whether the field has a numeric data type.
    var isNumeric: Bool {
        self == .float32 || self == .float64 || self == .int16 || self == .int32 || self == .int64
    }
    
    /// A Boolean value indicating whether the field has a floating point data type.
    var isFloatingPoint: Bool {
        self == .float32 || self == .float64
    }
}
