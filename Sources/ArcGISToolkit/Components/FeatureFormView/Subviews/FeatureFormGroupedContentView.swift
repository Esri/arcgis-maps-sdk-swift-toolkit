// Copyright 2025 Esri
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

/// A view to display grouped content together within a ScrollView.
struct FeatureFormGroupedContentView<Content: View>: View {
    let content: [Content]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(content.enumerated().map({ ($0.offset, $0.element) }), id: \.0) { (offset, content) in
                content
                if offset+1 != self.content.count {
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .formInputStyle()
    }
}

#Preview {
    ScrollView {
        FeatureFormGroupedContentView(content: [
            Button { } label: {
                Text("A Button")
                Spacer()
                Image(systemName: "chevron.right")
            }
        ])
        
        FeatureFormGroupedContentView(content: [
            Text("Text 1"), Text("Text 2")
        ])
        
        FeatureFormGroupedContentView(content: [
            NavigationLink("Navigation Link 1", value: 1),
            NavigationLink("Navigation Link 2", value: 2),
            NavigationLink("Navigation Link 3", value: 3)
        ])
    }
}
