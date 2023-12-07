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

/// An error that can be encountered while performing text validation.
enum TextValidationError {
    /// The text field was left empty but a value is required.
    case emptyWhenRequired
    /// The text field has too few or too many characters.
    case minOrMaxUnmet
    /// The text field contains a value that does not represent a whole number.
    case nonInteger
    /// The text field contains a value that does not represent a fractional number.
    case nonDecimal
    /// The text number value is out of range.
    case outOfRange
}
