// Copyright 2026 Esri
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
import Observation

@MainActor @Observable
class FilterViewModel {
    var featureTable: ArcGISFeatureTable?
    var fieldFilters: [FieldFilter]
    
    var fields = [Field]()
    
    func whereClause() -> String {
        var clause = ""
        for fieldFilter in fieldFilters {
            // Assemble where clause
        }
        return clause
    }
    
    /// Initializes a filter view model.
    /// - Parameter featureTable: The feature table for the filter.
    init(featureTable: ArcGISFeatureTable? = nil, fieldFilters: [FieldFilter] = [FieldFilter]()) {
        self.featureTable = featureTable
        self.fieldFilters = fieldFilters
        if let featureTable {
            Task {
                try? await featureTable.load()
                fields = featureTable.fields
                print("field: \(fields)")
            }
        }
    }
}

struct FieldFilter {
    var field: Field?
    var operation = UtilityNetworkAttributeComparison.Operator.equal
    var value: Any = ""
    var formattedValue: String = {
        // Get string value from `value`
        return "formattedValue"
    }()
}

extension FieldFilter: Equatable {
    static func == (lhs: FieldFilter, rhs: FieldFilter) -> Bool {
        lhs.field == rhs.field &&
        lhs.operation == rhs.operation// &&
//        rhs.value == lhs.value
    }
    
    
}

extension FieldFilter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(field?.hashValue)
        hasher.combine(operation.hashValue)
//        hasher.combine(value.hashValue)
    }
}


//private fun List<Field>.getSupportedFields(): List<Field> {
//    return filter { field ->
//        field.fieldType.isNumeric ||
//            field.fieldType == FieldType.Text ||
//            field.fieldType == FieldType.Oid
//    }
//}
