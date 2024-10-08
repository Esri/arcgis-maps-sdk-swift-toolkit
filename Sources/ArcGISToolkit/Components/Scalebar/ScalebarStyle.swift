// Copyright 2022 Esri
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

/// Visual scalebar styles.
@available(visionOS, unavailable)
public enum ScalebarStyle: Sendable {
    /// Displays a single unit with segmented bars of alternating fill color.
    case alternatingBar
    
    /// Displays a single unit.
    case bar
    
    /// Displays both metric and imperial units. The primary unit is displayed on top.
    case dualUnitLine
    
    /// Displays a single unit with tick marks.
    case graduatedLine
    
    /// Displays a single unit with endpoint tick marks.
    case line
}
