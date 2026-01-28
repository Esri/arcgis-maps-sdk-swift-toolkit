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
            if let index = fieldFilters.firstIndex(of: fieldFilter),
               index >= 1 {
                clause.append(" AND ")
            }
            clause.append(fieldFilter.query())
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

@Observable
class FieldFilter {
    let id = UUID()
    var field: Field {
        didSet {
            print("oldValue: \(oldValue.title()), newValue: \(field.title())")
            if oldValue !== field {
             // We're changing the field, so reset the condition
                condition = firstCondition()
            }
        }
    }
    var name = "Condition"
    var condition: FilterOperator = FilterOperator.equal
    var value = ""

    init(
        field: Field,
        name: String = "Condition",
        condition: FilterOperator = FilterOperator.equal,
        value: String = ""
    ) {
        self.field = field
        self.name = name
        self.condition = condition
        self.value = value
        self.condition = firstCondition()
    }
    
    func query() -> String {
        switch condition {
        case .startsWith:
            return "\(field.name) \(condition.sqlOperator) '\(value)%'"
        case .endsWith:
            return "\(field.name) \(condition.sqlOperator) '%\(value)'"
        case .contains,
                .doesNotContain:
            return "\(field.name) \(condition.sqlOperator) '%\(value)%'"
        case .isBlank,
                .isNotBlank,
                .isEmpty,
                .isNotEmpty:
            return "\(field.name) \(condition.sqlOperator)"   // unary: no RHS value
        case .equal,
                .notEqual,
                .isOp,
                .isNot,
                .greaterThan,
                .greaterThanOrEqual,
                .lessThan,
                .lessThanOrEqual:
            return "\(field.name) \(condition.sqlOperator) \(value)"
        }
    }
    
    private func firstCondition() -> FilterOperator {
        let conditions = (field.type?.isNumeric ?? false) ? FilterOperator.numericFilterOperators() : FilterOperator.textFilterOperators(field.isNullable)
        return conditions.first ?? FilterOperator.equal
    }
}

extension FieldFilter {
    func copy() -> FieldFilter {
        FieldFilter(
            field: self.field,
            name: self.name,
            condition: self.condition,
            value: self.value
        )
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

enum FilterOperator: String {
    case equal = "="
    case notEqual = "!="
    case isOp = "is"
    case isNot = "is not"
    case greaterThan = ">"
    case greaterThanOrEqual = ">="
    case lessThan = "<"
    case lessThanOrEqual = "<="
    case startsWith = "starts with"
    case endsWith = "ends with"
    case contains = "contains the text"
    case doesNotContain = "does not contain the text"
    case isBlank = "is blank"
    case isNotBlank = "is not blank"
    case isEmpty = "is empty"
    case isNotEmpty = "is not empty"

    static func textFilterOperators(_ fieldIsNullable: Bool) -> [FilterOperator] {
        var ops: [FilterOperator] = [
            .isOp,
            .isNot,
            .startsWith,
            .endsWith,
            .contains,
            .doesNotContain,
            .isEmpty,
            .isNotEmpty
        ]
        if fieldIsNullable {
            ops.append(contentsOf: [.isBlank, .isNotBlank])
        }
        return ops
    }

    static func numericFilterOperators() -> [FilterOperator] { [
            .equal,
            .notEqual,
            .greaterThan,
            .greaterThanOrEqual,
            .lessThan,
            .lessThanOrEqual
        ] }

    var sqlOperator: String {
        switch self {
        case .equal, .isOp:
            return "="
        case .notEqual, .isNot:
            return "<>"
        case .greaterThan:
            return ">"
        case .greaterThanOrEqual:
            return ">="
        case .lessThan:
            return "<"
        case .lessThanOrEqual:
            return "<="
        case .startsWith, .endsWith, .contains:
            return "LIKE"
        case .doesNotContain:
            return "not LIKE"
        case .isBlank:
            return "IS NULL"
        case .isNotBlank:
            return "IS NOT NULL"
        case .isEmpty:
            return "= ''"
        case .isNotEmpty:
            return "<> ''"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}
