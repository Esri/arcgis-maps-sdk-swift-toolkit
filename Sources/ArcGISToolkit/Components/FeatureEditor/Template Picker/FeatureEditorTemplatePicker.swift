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

import SwiftUI

/// A view that displays a list of feature templates.
struct FeatureEditorTemplatePicker: View {
    @Environment(FeatureEditorModel.self) private var model
    
    var body: some View {
        ContentUnavailableView("Under Construction", systemImage: "exclamationmark.triangle")
            .navigationTitle(
                LocalizedStringResource(
                    "Templates",
                    bundle: .toolkit,
                    comment: "The title of the template picker view"
                )
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButton(kind: .close) {
                        withAnimation {
                            model.stopEditing()
                        }
                    }
                }
            }
    }
}
