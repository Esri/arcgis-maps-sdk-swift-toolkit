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

import Foundation

extension String {
    /// A localized string for the word "Cancel".
    static var cancel: Self {
        .init(
            localized: "Cancel",
            bundle: .toolkitModule,
            comment: "A label for a button to cancel an operation."
        )
    }
    
    /// A localized string for the word "Clear".
    static var clear: Self {
        .init(
            localized: "Clear",
            bundle: .toolkitModule,
            comment: "E.g. Remove text from a text field."
        )
    }
    
    /// A localized string for the word "Close".
    static var close: Self {
        .init(
            localized: "Close",
            bundle: .toolkitModule,
            comment: "A label for a button indicating that the view should be closed."
        )
    }
    
    /// A localized string for the word "Dismiss".
    static var dismiss: Self {
        .init(
            localized: "Dismiss",
            bundle: .toolkitModule,
            comment: "E.g. Close/hide a sheet or pop-up."
        )
    }
    
    /// An error message explaining attachments with empty files (0 bytes) cannot be downloaded.
    static var emptyAttachmentDownloadErrorMessage: Self {
        .init(
            localized: "Empty attachments cannot be downloaded.",
            bundle: .toolkitModule,
            comment: "An error message explaining attachments with empty files (0 bytes) cannot be downloaded."
        )
    }
    
    /// A localized string for the word "Field".
    static var field: Self {
        .init(
            localized: "Field",
            bundle: .toolkitModule,
            comment: "A field in a set of data contained in a popup."
        )
    }
    
    /// A localized string for the phrase "No Value".
    static var noValue: Self {
        .init(
            localized: "No Value",
            bundle: .toolkitModule,
            comment: "A string indicating that no value has been set for a form field."
        )
    }
    
    /// A label for a button to take the user to a contextually inferred settings page.
    static var settings: String {
        .init(
            localized: "Settings",
            bundle: .toolkitModule,
            comment: "A label for a button to take the user to a contextually inferred settings page."
        )
    }
    
    /// A localized string for the word "Value".
    static var value: Self {
        .init(
            localized: "Value",
            bundle: .toolkitModule,
            comment: "A value in a set of data contained in a popup."
        )
    }
}
