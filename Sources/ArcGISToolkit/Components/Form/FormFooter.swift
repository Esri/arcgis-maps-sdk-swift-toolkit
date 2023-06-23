// Copyright 2023 Esri.

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

/// A view shown at the bottom of a form with buttons to cancel or submit the form.
struct FormFooter: View {
    /// The closure to execute when the submit button is pressed.
    let onSubmit: () -> Void
    
    /// The closure to execute when the cancel button is pressed.
    let onCancel: () -> Void
    
    var body: some View {
        HStack {
            makeCancelButton()
                .padding([.horizontal])
            
            makeSubmitButton()
                .padding([.horizontal])
        }
    }
    
    /// A button to cancel a form.
    func makeCancelButton() -> some View {
        Button(role: .cancel) {
            onCancel()
        } label: {
            Text(
                "Cancel",
                bundle: .toolkitModule,
                comment: "A label for a button to cancel a form."
            )
        }
        .buttonStyle(.bordered)
    }
    
    /// A button to submit a form.
    func makeSubmitButton() -> some View {
        Button {
            onSubmit()
        } label: {
            Text(
                "Submit",
                bundle: .toolkitModule,
                comment: "A label for a button to submit changes in a form."
            )
        }
        .buttonStyle(.borderedProminent)
    }
}
