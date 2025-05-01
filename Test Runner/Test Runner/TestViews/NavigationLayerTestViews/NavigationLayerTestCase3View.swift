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

@testable import ArcGISToolkit
import SwiftUI

/// A view using NavigationLayer where the current presented item is tracked with
/// `onNavigationPathChanged(perform:)`.
struct NavigationLayerTestCase3View: View {
    @State private var presentedViewType: String?
    
    var body: some View {
        NavigationLayer { model in
            List {
                Button("Present a view") {
                    model.push {
                        DemoView()
                    }
                }
            }
        } footer: {
            Text(presentedViewType ?? "Root view")
        }
        .onNavigationPathChanged { item in
            if let item {
                presentedViewType = "\(type(of: item.view()))"
            } else {
                presentedViewType = nil
            }
        }
    }
}

extension NavigationLayerTestCase3View {
    struct DemoView: View {
        var body: some View {
            List { }
        }
    }
}
