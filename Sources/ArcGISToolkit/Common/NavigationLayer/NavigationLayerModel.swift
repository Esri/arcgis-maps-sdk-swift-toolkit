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

class NavigationLayerModel: ObservableObject {
    /// An item representing a view pushed on the layer.
    struct Item {
        /// The closure which produces the view for the item.
        let view: () -> any View
    }
    
    /// The transition for the next time a view is appended or removed.
    @Published private(set) var transition: AnyTransition = .push
    
    /// The set of views pushed on the layer.
    @Published private(set) var views: [Item] = []
    
    /// The title for the current destination.
    @Published var title: String? = nil
    
    /// The subtitle for the current destination.
    @Published var subtitle: String? = nil
    
    /// The currently presented view (the last item).
    var presented: Item? {
        views.last
    }
    
    /// Pop the current view.
    func pop() {
        guard !views.isEmpty else { return }
        transition = .pop
        withAnimation {
            _ = views.removeLast()
        }
    }
    
    /// Push a view.
    /// - Parameter view: The view to push.
    func push(_ view: @escaping () -> any View) {
        transition = .push
        withAnimation {
            views.append(.init(view: view))
        }
    }
}
