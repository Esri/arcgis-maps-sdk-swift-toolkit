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

@Observable class NavigationLayerModel {
    /// An item representing a view pushed on the layer.
    struct Item {
        /// The view for the item.
        let view: any View
    }
    
    /// A Boolean value indicating whether another view is being pushed.
    private var isPushing = false
    
    /// The transition for the next time a view is appended or removed.
    private(set) var transition: AnyTransition = .push
    
    /// The set of views pushed on the layer.
    private(set) var views: [Item] = []
    
    /// The header background color for the current view.
    var headerBackgroundColor: Color?
    
    /// The title for the current view.
    var title: String?
    
    /// The subtitle for the current view.
    var subtitle: String?
    
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
    
    /// Pops all of the views in the stack.
    func popAll() {
        guard !views.isEmpty else { return }
        
        transition = .pop
        withAnimation {
            views.removeAll()
        }
    }
    
    /// Push a view.
    /// - Parameter view: The view to push.
    func push(_ view: @escaping () -> any View) {
        // Prevent the same view from being pushed multiple times while the
        // animation is running.
        // In UI tests we don't need to guard against this condition and the
        // guard actually becomes harmful, as there is no accepted pattern for
        // waiting for animations to complete so tests have no reliable way of
        // determining when to push the next view.
        if !isUITest {
            guard !isPushing else { return }
            isPushing = true
        }
        
        transition = .push
        
        withAnimation {
            views.append(.init(view: view()))
        } completion: {
            self.isPushing = false
        }
    }
    
    /// A Boolean value which indicates whether a UI Test is running.
    private var isUITest: Bool {
        CommandLine.arguments.contains("isUITest")
    }
}
