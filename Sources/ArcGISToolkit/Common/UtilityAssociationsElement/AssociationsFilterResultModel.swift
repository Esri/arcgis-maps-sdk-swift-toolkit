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
    
    /// Fetches the associations filter results from a given associations element.
    /// - Parameter element: The element containing the associations filter results.
    @MainActor
    init(element: UtilityAssociationsElement) {
        task = Task { [weak self] in
            guard !Task.isCancelled, let self else {
                return
            }
            
            let result = await Result {
                try await element.associationsFilterResults.filter { $0.resultCount > 0 }
            }
            withAnimation {
                self.result = result
            }
        }
    }
    
    deinit {
        task?.cancel()
    }
}
