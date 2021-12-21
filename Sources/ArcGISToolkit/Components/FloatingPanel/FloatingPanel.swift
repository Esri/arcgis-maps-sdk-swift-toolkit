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
//import ArcGIS

public struct FloatingPanel<Content> : View where Content : View {
    /// The content that is to be housed in the floating panel.
    let content: Content
    
    public init(
        content: Content
    ) {
        self.content = content
    }
    
    @State
    var handleColor: Color = .secondary
    
    var drag: some Gesture {
        DragGesture()
        //            .onChanged { self.heightOffset = $0.translation.height}
            .onChanged {
                self.handleColor = .red
                self.heightOffset = $0.translation.height
                lastHeight = originalHeight + heightOffset
            }
            .onEnded { _ in
                self.handleColor = .secondary
                self.originalHeight = lastHeight
            }
    }
    
    @State
    private var heightOffset: CGFloat = 0
    
    @State
    private var originalHeight: CGFloat = 0
    @State
    private var lastHeight: CGFloat = 0

    //    private var currentHeight: CGFloat = 0
    
    public var body: some View {
        VStack(alignment: .center) {
            GeometryReader { geometry in
                content
                    .frame(height: originalHeight + heightOffset)
                    .onAppear {
                        if originalHeight == 0 {
                            originalHeight = geometry.size.height
                        }
                    }
            }
            //            Rectangle()
            //                .foregroundColor(.secondary)
            //                .frame(height: 1.0)
            Rectangle()
                .foregroundColor(handleColor)
                .frame(width: 100, height: 8.0)
                .cornerRadius(4.0)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                .gesture(drag)
            Text("\(self.heightOffset)")
        }
        .frame(width: 300)
        .esriBorder(padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        Spacer()
    }
}

struct FloatingPanel_Previews: PreviewProvider {
    static var previews: some View {
        FloatingPanel(content: Rectangle().foregroundColor(.blue))
    }
}
