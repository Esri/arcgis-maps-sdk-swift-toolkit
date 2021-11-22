// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A value that represents an error that occurs while searching.
public struct SearchError: Error {
    /// A basic description for the error.
    public let errorDescription: String
}

extension SearchError {
    init(_ error: Error) {
        self.init(
            errorDescription: error.localizedDescription
        )
    }
}

extension SearchError: Equatable {}
