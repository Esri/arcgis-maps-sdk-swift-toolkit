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

public struct FloatingPanel<Content> : View where Content : View {
    /// The content that is to be housed in the floating panel.
    let content: Content
    
    public init(content: Content) {
        self.content = content
    }
    
    @State
    var handleColor: Color = .secondary
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.handleColor = .red
                height = max(minHeight, (height ?? 0) + value.translation.height)
            }
            .onEnded { _ in
                self.handleColor = .secondary
            }
    }

    private let minHeight: CGFloat = 44
    
    @State var height: CGFloat? = nil
    
    public var body: some View {
        VStack {
            VStack {
                content
                    .frame(minHeight: minHeight, maxHeight: height)
                Rectangle()
                    .foregroundColor(handleColor)
                    .frame(width: 100, height: 8.0)
                    .cornerRadius(4.0)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                    .gesture(drag)
            }
            .esriBorder(padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            Spacer()
        }
    }
}
