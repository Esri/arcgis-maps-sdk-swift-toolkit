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

extension Sequence {
    /// Returns a sequence with only the unique elements of this sequence,
    /// in the order of the first occurrence of each unique element. The method
    /// is adapted from Swift Algorithms.
    ///
    ///     let animals = ["dog", "pig", "cat", "ox", "dog", "cat"]
    ///     let uniqued = animals.uniqued()
    ///     print(Array(uniqued))
    ///     // Prints '["dog", "pig", "cat", "ox"]'
    ///
    /// - Returns: A sequence with only the unique elements of this sequence.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    @inlinable
    func uniqued() -> [Element] where Element: Hashable {
        var seen: Set<Element> = []
        var result: [Element] = []
        for element in self {
            if seen.insert(element).inserted {
                result.append(element)
            }
        }
        return result
    }
}
