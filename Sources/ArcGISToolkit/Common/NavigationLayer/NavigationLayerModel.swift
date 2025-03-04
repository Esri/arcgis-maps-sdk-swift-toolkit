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
    struct Item {
        let title: String?
        
        let subtitle: String?
        
        let view: () -> any View
    }
    
    @Published private(set) var transition: AnyTransition = .push
    
    @Published private(set) var views: [Item] = []
    
    /// <#Description#>
    @Published var footerContent: (() -> (any View))?
    
    var presented: Item? {
        views.last
    }
    
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
        push(.init(title: nil, subtitle: nil, view: view))
    }
    
    /// Push a view with a title.
    /// - Parameters:
    ///   - title: The title for the view.
    ///   - view: The view to push.
    func push(title: String, _ view: @escaping () -> any View) {
        push(.init(title: title, subtitle: nil, view: view))
    }
    
    /// Push a view with a title and subtitle.
    /// - Parameters:
    ///   - title: The title for the view.
    ///   - subtitle: The subtitle for the view.
    ///   - view: The view to push.
    func push(title: String, subtitle: String, _ view: @escaping () -> any View) {
        push(.init(title: title, subtitle: subtitle, view: view))
    }
    
    private func push(_ view: Item) {
        transition = .push
        withAnimation {
            views.append(view)
        }
    }
}
