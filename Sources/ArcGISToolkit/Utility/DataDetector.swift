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

/// Matches natural language text for predefined data patterns including hyperlinks and phone number.
struct DataDetector {
    struct DetectedValue {
        let url: URL
        let range: NSRange
    }
    
    /// Detects hyperlinks and phone numbers in text.
    /// - Parameter text: The text to search.
    func detect(in text: String) -> [DetectedValue]? {
        let types: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return nil
        }
        
        let fullRange = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: fullRange)
        
        return matches.compactMap { match in
            if let phone = match.phoneNumber {
                let cleaned = phone
                    .components(separatedBy: .decimalDigits.inverted)
                    .joined()
                guard let url = URL(string: "tel:\(cleaned)") else { return nil }
                return .init(url: url, range: match.range)
            } else if let url = match.url {
                return .init(url: url, range: match.range)
            } else {
                return nil
            }
        }
    }
}
