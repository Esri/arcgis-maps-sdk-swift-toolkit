// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A style in which a toggle button appears to be either selected or deselected depending on the toggle's current state.
struct SelectableButtonStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        if configuration.isOn {
            Button {
                configuration.isOn.toggle()
            } label: {
                configuration.label
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button {
                configuration.isOn.toggle()
            } label: {
                configuration.label
            }
            .buttonStyle(.bordered)
        }
    }
}

/// A style in which a toggle button appears to be always selected despite the toggle's current state.
struct SelectedButtonStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(.borderedProminent)
    }
}

extension ToggleStyle where Self == SelectableButtonStyle {
    /// Appears as a selected or deselected button despending on the toggle's current state.
    static var selectableButton: SelectableButtonStyle { .init() }
}

extension ToggleStyle where Self == SelectedButtonStyle {
    /// Appears always a selected button despite the toggle's current state.
    static var selectedButton: SelectedButtonStyle { .init() }
}
