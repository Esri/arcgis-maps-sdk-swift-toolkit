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
import Combine

/// Shared prototype attachment options used by import and preview controls.
final class AttachmentPrototypeOptions: ObservableObject {
    /// Default values sourced from the form element.
    struct Defaults {
        let allowUserRename: Bool
        let displayFilename: Bool
        let useOriginalFilename: Bool
        let minAttachmentCount: UInt32
        let maxAttachmentCount: UInt32
    }

    @Published var isEnabled = false
    @Published var allowUserRename = false
    @Published var displayFilename = true
    @Published var useOriginalFilename = true
    @Published var enforceAttachmentCountLimits = false
    @Published var minAttachmentCount: UInt32 = 0
    @Published var maxAttachmentCount: UInt32 = .max
    @Published var customFilename = ""
    @Published var sessionAttachmentCount: UInt32 = 0

    func apply(defaults: Defaults) {
        allowUserRename = defaults.allowUserRename
        displayFilename = defaults.displayFilename
        useOriginalFilename = defaults.useOriginalFilename
        minAttachmentCount = defaults.minAttachmentCount
        maxAttachmentCount = defaults.maxAttachmentCount
        customFilename = ""
        sessionAttachmentCount = 0
    }
}