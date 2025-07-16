// Copyright 2023 Esri
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

import SwiftUI

extension Text {
    /// Localized text for the word "Cancel".
    static var cancel: Self {
        .init(LocalizedStringResource.cancel)
    }
    
    /// Localized text for the word "Done".
    static var done: Self {
        .init(
            "Done",
            bundle: .toolkitModule,
            comment: "A label for a button for the user to indicate completion of the current task."
        )
    }
    
    /// Localized text for the phrase "No Associations".
    static var noAssociations: Self {
        .init(
            "No Associations",
            bundle: .toolkitModule,
            comment: "A label indicating that no associations are available for the utility associations element."
        )
    }
    
    /// Localized text for the word "Rename".
    static var rename: Self {
        Text(
            "Rename",
            bundle: .toolkitModule,
            comment: "A label for a button to rename an attachment."
        )
    }
    
    /// Localized text for the word "Required".
    static var required: Self {
        Text(
            "Required",
            bundle: .toolkitModule,
            comment: "A label indicating a field is required"
        )
    }
    
    /// Localized text for the phrase "Try Again".
    static var tryAgain: Self {
        .init(
            "Try Again",
            bundle: .toolkitModule,
            comment: "A label for a button allowing the user to retry an operation."
        )
    }
    
    static func makeErrorFetchingFilterResultsMessage(_ error: any Error) -> Self {
        .init(
            "Error fetching filter results: \(error.localizedDescription)",
            bundle: .toolkitModule,
            comment: """
                     An error message shown when the element's
                     associations filter results cannot be displayed.
                     The variable provides additional data.
                     """
        )
    }
}
