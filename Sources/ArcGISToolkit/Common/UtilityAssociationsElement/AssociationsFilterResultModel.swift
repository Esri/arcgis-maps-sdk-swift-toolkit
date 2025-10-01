// Copyright 2025 Esri
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

/// A view model for fetching associations filter results.
@Observable
final class AssociationsFilterResultsModel {
    /// The result of fetching the associations filter results.
    private(set) var result: Result<[UtilityAssociationsFilterResult], Error>?
    
    /// The task for fetching the associations filter results.
    @ObservationIgnored private var task: Task<Void, Never>?
    
    /// The element containing the association filters.
    let element: UtilityAssociationsElement
    
    /// A Boolean value which determines if empty filter results are included.
    let includeEmptyFilterResults: Bool
    
    /// - Parameters:
    ///   - element: The element containing the association filters.
    ///   - includeEmptyFilterResults: A Boolean value which determines if empty filter results are included. `False` by default.
    @MainActor
    init(element: UtilityAssociationsElement, includeEmptyFilterResults: Bool = false) {
        self.element = element
        self.includeEmptyFilterResults = includeEmptyFilterResults
        fetchResults()
    }
    
    /// Fetches the associations filter results from a given associations element.
    @MainActor
    func fetchResults() {
        let element = self.element
        task?.cancel()
        task = Task { [weak self, includeEmptyFilterResults] in
            guard !Task.isCancelled, let self else { return }
            let result = await Result {
                let allResults = try await element.associationsFilterResults
                return if includeEmptyFilterResults {
                    allResults
                } else {
                    allResults.filter { $0.resultCount > 0 }
                }
            }
            withAnimation { self.result = result }
        }
    }
    
    deinit {
        task?.cancel()
    }
}
