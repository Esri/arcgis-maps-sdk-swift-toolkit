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
import Foundation
import SwiftUI

@MainActor @Observable
class FilterViewModel {
    /// The feature table containing the fields to filter on.
    public var featureTable: ArcGISFeatureTable? {
        didSet {
            if let featureTable {
                Task {
                    try? await featureTable.load()
                    fields = supportedUNFields(featureTable.fields)
                }
            }
        }
    }
    /// The list of field filters the user has created.
    var fieldFilters = [FieldFilter]()
    
    /// The original list of field filters, used when user cancels changes.
    private var originalFieldFilters = [FieldFilter]()
    
    /// A Boolean value indicating whether the filter view is presented.
    var filterViewIsPresented = false
    
    /// The list of fields generated from the `featureTable`.
    private(set) var fields = [Field]()
    
    /// Specifies whether the list of Field Filters has changed since the last invocation.
    var hasChanges: Bool {
        guard fieldFilters.count == originalFieldFilters.count else { return true }
        var filtersEqual = true
        for i in 0..<fieldFilters.count {
            let filter = fieldFilters[i]
            let originalFilter = originalFieldFilters[i]
            guard filter == originalFilter else { return true }
        }
        return false
    }

    /// The "where" clause assembled from the list of `FieldFilters`
    /// - Returns: A string represented the SQL query assembled from the list of `FieldFilters`. The `FieldFilters` are joined by `AND`.
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
    init(featureTable: ArcGISFeatureTable? = nil) {
        self.featureTable = featureTable
    }
    
    /// Applies the current field filters.
    func apply() {
        filterViewIsPresented.toggle()
        originalFieldFilters = fieldFilters.map { $0.copy() }
    }
    
    /// Cancels the current changes to the field filters.
    func cancel() {
        filterViewIsPresented.toggle()
        fieldFilters = originalFieldFilters.map { $0.copy() }
    }
}

/// A class representing a single filter operation.
@Observable
class FieldFilter {
    /// The id of the filter.
    let id = UUID()
    
    /// The field being filtered on.
    var field: Field {
        didSet {
            if oldValue !== field {
                // We're changing the field, so reset the condition
                condition = firstCondition()
            }
        }
    }
    
    /// The operation used specify how the `value` should be applied to the `field`.
    var condition: FilterOperator = FilterOperator.equal
    
    /// A date value for date pickers to bind to.
    var dateValue: Date {
        didSet {
            guard field.type == .date || field.type == .dateOnly else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate(
                field.type == .dateOnly ? "MMM dd, yyyy" : "MMM dd, yyyy h:mm a"
            )
            value = dateFormatter.string(from: dateValue)
        }
    }
    
    /// The value to filter on.
    var value = ""
    
    init(
        field: Field,
    ) {
        self.dateValue = .now
        self.field = field
        self.condition = firstCondition()
    }
    
    init(
        field: Field,
        condition: FilterOperator,
        dateValue: Date,
        value: String = ""
    ) {
        self.field = field
        self.condition = condition
        self.dateValue = dateValue
        self.value = value
    }
    
    /// Creates the SQL query for this field filter.
    /// - Returns: A string representing a SQL query for the specified `field`, `condition`, and `value`.
    func query() -> String {
        switch condition {
        case .startsWith:
            "\(field.name) \(condition.sqlOperator) '\(value)%'"
        case .endsWith:
            "\(field.name) \(condition.sqlOperator) '%\(value)'"
        case .contains, .doesNotContain:
            "\(field.name) \(condition.sqlOperator) '%\(value)%'"
        case .isBlank, .isNotBlank, .isEmpty, .isNotEmpty:
            "\(field.name) \(condition.sqlOperator)"
        case .equal, .notEqual, .isOp, .isNot, .greaterThan, .greaterThanOrEqual, .lessThan, .lessThanOrEqual:
            "\(field.name) \(condition.sqlOperator) \(value)"
        }
    }
    
    /// Determines the appropriate set of filter operators for a field, depending on whether the field is numeric or textual.
    /// It then returns the first available filter operator from that set. If no operators are found, it defaults to .equal.
    /// - Returns: The first available filter operator from the appropriate set of filters.
    private func firstCondition() -> FilterOperator {
        let conditions = (field.type?.isNumeric ?? false) ? FilterOperator.numericFilterOperators() : FilterOperator.textFilterOperators(field.isNullable)
        return conditions.first ?? FilterOperator.equal
    }
}

extension FieldFilter {
    /// Copies a `FieldFilter`
    /// - Returns: An exact copy of `FieldFilter`.
    func copy() -> FieldFilter {
        FieldFilter(
            field: self.field,
            condition: self.condition,
            dateValue: self.dateValue,
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
    /// Returns the list of fields supported for filtering.
    /// - Parameter allFields: The list of all candidate fields to filter by.
    /// - Returns: The final list of supported fields to filter by.
    private func supportedFields(_ allFields: [Field]) -> [Field] {
        allFields.filter { field in
            (field.type?.isNumeric ?? false) ||
            field.type == .date ||
            field.type == .dateOnly ||
            field.type == .oid ||
            field.type == .text
        }
    }
    
    /// Returns the list of fields supported for filtering by when used in a Utility Network workflow.
    /// - Parameter allFields: The list of all candidate fields to filter by.
    /// - Returns: The final list of supported fields to filter by. This will automatically filter out the
    /// `ASSETGROUP` and `ASSETTYPE` fields, as those are special fields for Utility Networks.
    private func supportedUNFields(_ allFields: [Field]) -> [Field] {
        supportedFields(allFields).filter { field in
            field.name != "assetgroup" && field.name != "assettype"
        }
    }
}

/// All of the available filter operations.
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
    
    /// Returns a list of appropriate operations for text fields.
    /// - Parameter fieldIsNullable: Specifies whether the field is nullable; if `true`, `empty` and `notEmpty` operators
    /// are added to the list. If `false`, no additional operators are added.
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
    
    /// Returns a list of appropriate operations for numeric fields.
    static func numericFilterOperators() -> [FilterOperator] { [
        .equal,
        .notEqual,
        .greaterThan,
        .greaterThanOrEqual,
        .lessThan,
        .lessThanOrEqual
    ] }
    
    /// The SQL operator string represented by the operator.
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
    
    /// The name used to display the operator.
    var displayName: Text {
        switch self {
        case .isOp:
            Text(
                "is",
                bundle: .toolkitModule,
                comment: "A label for the \"is\" attribute query condition."
            )
        case .isNot:
            Text(
                "is not",
                bundle: .toolkitModule,
                comment: "A label for the \"is not\" attribute query condition."
            )
        case .startsWith:
            Text(
                "starts with",
                bundle: .toolkitModule,
                comment: "A label for the \"starts with\" attribute query condition."
            )
        case .endsWith:
            Text(
                "ends with",
                bundle: .toolkitModule,
                comment: "A label for the \"ends with\" attribute query condition."
            )
        case .contains:
            Text(
                "contains the text",
                bundle: .toolkitModule,
                comment: "A label for the \"contains the text\" attribute query condition."
            )
        case .doesNotContain:
            Text(
                "does not contain the text",
                bundle: .toolkitModule,
                comment: "A label for the \"does not contain the text\" attribute query condition."
            )
        case .isBlank:
            Text(
                "is blank",
                bundle: .toolkitModule,
                comment: "A label for the \"is blank\" attribute query condition."
            )
        case .isNotBlank:
            Text(
                "is not blank",
                bundle: .toolkitModule,
                comment: "A label for the \"is not blank\" attribute query condition."
            )
        case .isEmpty:
            Text(
                "is empty",
                bundle: .toolkitModule,
                comment: "A label for the \"is empty\" attribute query condition."
            )
        case .isNotEmpty:
            Text(
                "is not empty",
                bundle: .toolkitModule,
                comment: "A label for the \"is not empty\" attribute query condition."
            )
        default:
            Text(self.rawValue)
        }
    }
}
