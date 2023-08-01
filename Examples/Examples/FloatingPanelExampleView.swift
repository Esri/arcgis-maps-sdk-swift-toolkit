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
import ArcGISToolkit
import ArcGIS

struct FloatingPanelExampleView: View {
    /// The data model containing the `Map` displayed in the `MapView`.
    @StateObject private var dataModel = MapDataModel(
        map: Map(basemapStyle: .arcGISImagery)
    )
    
    /// The Floating Panel's current content.
    @State private var demoContent: FloatingPanelDemoContent?
    
    /// The Floating Panel's current detent.
    @State private var selectedDetent: FloatingPanelDetent = .half
    
    /// The initial viewpoint shown in the map.
    private let initialViewpoint = Viewpoint(
        center: Point(x: -93.258133, y: 44.986656, spatialReference: .wgs84),
        scale: 1_000_000
    )
    
    var body: some View {
        MapView(
            map: dataModel.map,
            viewpoint: initialViewpoint
        )
        .floatingPanel(selectedDetent: $selectedDetent, isPresented: isPresented) {
            switch demoContent {
            case .list:
                FloatingPanelListDemoContent(selectedDetent: $selectedDetent)
            case .textField:
                FloatingPanelTextFieldDemoContent()
            case .none:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("List") {
                        demoContent = .list
                    }
                    Button("Text Field") {
                        demoContent = .textField
                    }
                } label: {
                    Text("Present")
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
    case textField
    case list
}

/// Demo content consisting of a list with inner sections each containing a set of buttons This
/// content also demonstrates the ability to control the Floating Panel's detent.
private struct FloatingPanelListDemoContent: View {
    @Binding var selectedDetent: FloatingPanelDetent
    
    var body: some View {
        List {
            Section("Preset Heights") {
                Button("Summary") {
                    selectedDetent = .summary
                }
                Button("Half") {
                    selectedDetent = .half
                }
                Button("Full") {
                    selectedDetent = .full
                }
            }
            Section("Fractional Heights") {
                Button("1/4") {
                    selectedDetent = .fraction(1 / 4)
                }
                Button("1/2") {
                    selectedDetent = .fraction(1 / 2)
                }
                Button("3/4") {
                    selectedDetent = .fraction(3 / 4)
                }
            }
            Section("Value Heights") {
                Button("200") {
                    selectedDetent = .height(200)
                }
                Button("600") {
                    selectedDetent = .height(600)
                }
            }
        }
    }
}

/// Demo content consisting of a vertical stack of items, including a text field which demonstrates
/// the Floating Panel's keyboard avoidance capability.
private struct FloatingPanelTextFieldDemoContent: View {
    @State private var sampleText = ""
    
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
            .textFieldStyle(.roundedBorder)
        }
    }
}
