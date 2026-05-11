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

import Foundation

struct HashableWrapper<T: AnyObject & Sendable>: Hashable, Sendable {
    let wrappedValue: T
    
    init(_ wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.wrappedValue === rhs.wrappedValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(wrappedValue))
    }
}
