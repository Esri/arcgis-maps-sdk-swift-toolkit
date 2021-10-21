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

import SwiftUI

/// A modifier which adds a "show results" button in a view, used to hide/show another view.
struct EsriShowResultsButtonViewModifier: ViewModifier {
    var isHidden: Bool
    @Binding var showResults: Bool
    
    func body(content: Content) -> some View {
        HStack {
            content
            if !isHidden {
                Button(
                    action: { showResults.toggle() },
                    label: {
                        Image(systemName: "eye")
                            .symbolVariant(!showResults ? .none : .slash)
                            .symbolVariant(.fill)
                            .foregroundColor(Color(.opaqueSeparator))
                    }
                )
            }
        }
    }
}

extension View {
    func esriShowResultsButton(
        isHidden: Bool,
        showResults: Binding<Bool>
    ) -> some View {
        modifier(EsriShowResultsButtonViewModifier(
            isHidden: isHidden,
            showResults: showResults
        ))
    }
}
