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

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct FloatingPanelExampleView: View {
    /// The height of the map view's attribution bar.
    @State private var attributionBarHeight: CGFloat = 0
    
    /// The Floating Panel's current content.
    @State private var demoContent: FloatingPanelDemoContent?
    
    /// The `Map` displayed in the `MapView`.
    @State private var map: Map = {
        let map = Map(basemapStyle: .arcGISImagery)
        map.initialViewpoint = Viewpoint(
            center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
            scale: 1_000_000
        )
        return map
    }()
    
    /// The Floating Panel's current detent.
    @State private var selectedDetent: FloatingPanelDetent = .half
    
    var body: some View {
        MapView(map: map)
            .onAttributionBarHeightChanged {
                attributionBarHeight = $0
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .floatingPanel(
                attributionBarHeight: attributionBarHeight,
                selectedDetent: $selectedDetent,
                isPresented: isPresented
            ) {
                if let demoContent {
                    switch demoContent {
                    case .list:
                        FloatingPanelListDemoContent(selectedDetent: $selectedDetent)
                    case .text:
                        FloatingPanelTextContent()
                    case .textField:
                        FloatingPanelTextFieldDemoContent(selectedDetent: $selectedDetent)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if demoContent != nil {
                        Button("Dismiss") {
                            demoContent = nil
                        }
                    } else {
                        Menu("Present") {
                            Button("List") {
                                demoContent = .list
                            }
                            Button("Text") {
                                demoContent = .text
                            }
                            Button("Text Field") {
                                demoContent = .textField
                            }
                        }
                    }
                }
            }
    }
    
    /// A Boolean value indicating whether the Floating Panel is displayed or not.
    var isPresented: Binding<Bool> {
        .init {
            demoContent != nil
        } set: { _ in
        }
    }
}

/// The types of content available for demo in the Floating Panel.
private enum FloatingPanelDemoContent {
    case list
    case text
    case textField
}

/// Demo content consisting of a list with inner sections each containing a set of buttons This
/// content also demonstrates the ability to control the Floating Panel's detent.
private struct FloatingPanelListDemoContent: View {
    @Binding var selectedDetent: FloatingPanelDetent
    
    var body: some View {
        List {
            Section("Preset Heights") {
                Button("Full") {
                    selectedDetent = .full
                }
                .disabled(selectedDetent == .full)
                Button("Half") {
                    selectedDetent = .half
                }
                .disabled(selectedDetent == .half)
                Button("Summary") {
                    selectedDetent = .summary
                }
                .disabled(selectedDetent == .summary)
            }
            Section("Fractional Heights") {
                Button("3/4") {
                    selectedDetent = .fraction(3 / 4)
                }
                .disabled(selectedDetent == .fraction(3 / 4))
                Button("1/2") {
                    selectedDetent = .fraction(1 / 2)
                }
                .disabled(selectedDetent == .fraction(1 / 2))
                Button("1/4") {
                    selectedDetent = .fraction(1 / 4)
                }
                .disabled(selectedDetent == .fraction(1 / 4))
            }
            Section("Value Heights") {
                Button("600") {
                    selectedDetent = .height(600)
                }
                .disabled(selectedDetent == .height(600))
                Button("200") {
                    selectedDetent = .height(200)
                }
                .disabled(selectedDetent == .height(200))
            }
        }
    }
}

/// Demo content consisting of a single instance of short text which demonstrates the Floating
/// Panel has a stable width, despite the width of its content.
private struct FloatingPanelTextContent: View {
    var body: some View {
        Text("Hello, world!")
    }
}

/// Demo content consisting of a vertical stack of items, including a text field which demonstrates
/// the Floating Panel's keyboard avoidance capability.
private struct FloatingPanelTextFieldDemoContent: View {
    @Binding var selectedDetent: FloatingPanelDetent
    
    @State private var sampleText = ""
    
    @FocusState private var isFocused
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Text Field")
                .font(.title)
            Text("The Floating Panel has built-in keyboard avoidance.")
                .font(.caption)
            TextField(
                "Text Field",
                text: $sampleText,
                prompt: Text("Enter sample text.")
            )
            .focused($isFocused)
            .textFieldStyle(.roundedBorder)
            Spacer()
        }
        .padding()
        .onChange(of: selectedDetent) {
            if selectedDetent != .full {
                isFocused = false
            }
        }
    }
}
