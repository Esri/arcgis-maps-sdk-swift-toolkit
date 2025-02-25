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

/// A view shown at the top of a form.
struct FormHeader: View {
    /// The title defined for the form.
    let title: String
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Text.discard
            }
//            .opacity(<#T##opacity: Double##Double#>)
            
            Spacer()
            
            Text(title)
                .bold()
            
            Spacer()
            
            Button {
                
            } label: {
                Text.finish
            }
//            .opacity(<#T##opacity: Double##Double#>)
        }
        .frame(maxWidth: .infinity)
    }
}

/// A view shown at the top of a form.
struct FormHeader: View {
    /// The title defined for the form.
    let title: String
    
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Text.discard
            }
            //            .opacity(<#T##opacity: Double##Double#>)
            
            Spacer()
            
            Text(title)
                .bold()
            
            Spacer()
            
            Button {
                
            } label: {
                Text.finish
            }
            //            .opacity(<#T##opacity: Double##Double#>)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension Text {
    /// A label for a button to discard edits to the feature form.
    static var discard: Self {
        .init(
            "Discard",
            bundle: .toolkitModule,
            comment: "A label for a button to discard edits to the feature form."
        )
    }
    
    /// A label for a button to finish editing the feature form.
    static var finish: Self {
        .init(
            "Finish",
            bundle: .toolkitModule,
            comment: "A label for a button to finish editing the feature form."
        )
    }
}
