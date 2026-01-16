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
import SwiftUI

@MainActor @Observable
class FilterViewModel {
    public var featureTable: ArcGISFeatureTable? {
        didSet {
            if let featureTable {
                Task {
                    try? await featureTable.load()
                    fields = supportedFields(featureTable.fields)
                    print("field: \(fields)")
                }
            }
        }
    }
    var fieldFilters: [FieldFilter]
    private var originalFieldFilters: [FieldFilter]
    var isFilterViewPresented = false

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
        self.originalFieldFilters = fieldFilters
    }
    
    func apply() {
        isFilterViewPresented.toggle()
        self.originalFieldFilters = fieldFilters
    }
    
    func cancel() {
        fieldFilters = originalFieldFilters
        isFilterViewPresented.toggle()
    }
}

class FieldFilter {
    let id = UUID()
    var field: Field
    var name = "Condition"
    var condition = UtilityNetworkAttributeComparison.Operator.equal
    var value: Any = ""
    var formattedValue = "dummy value"
//    var formattedValue: String = {
//        // Get string value from `value`
//        return "dummy value"
//    }()
    
    init(
        field: Field,
        name: String = "Condition",
        condition: UtilityNetworkAttributeComparison.Operator = .equal,
        value: Any = "",
        formattedValue: String = "dummy value"
    ) {
        self.field = field
        self.name = name
        self.condition = condition
        self.value = value
        self.formattedValue = formattedValue
    }
}

extension FieldFilter {
    func copy() -> FieldFilter {
        print("original: \(self)")
        let newFilter = FieldFilter(
            field: self.field,
            name: self.name,
            condition: self.condition,
            value: self.value,
            formattedValue: self.formattedValue
        )
        print("newFilter: \(newFilter)")
        return newFilter
    }
}

extension FieldFilter: Equatable {
    static func == (lhs: FieldFilter, rhs: FieldFilter) -> Bool {
        lhs.id == rhs.id
    }
}

extension FieldFilter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension FilterViewModel {
    private func supportedFields(_ allFields: [Field]) -> [Field] {
        allFields.filter { field in
            (field.type?.isNumeric ?? false) ||
            field.type == .text ||
            field.type == FieldType.oid
        }
    }
}
