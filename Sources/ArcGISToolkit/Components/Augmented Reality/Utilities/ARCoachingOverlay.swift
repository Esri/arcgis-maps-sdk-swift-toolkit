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

#if !os(visionOS)
import ARKit
import SwiftUI

/// A SwiftUI version of an ARCoachingOverlayView view.
struct ARCoachingOverlay {
    /// The closure to call when the coaching overlay view activates.
    private(set) var onCoachingOverlayActivateAction: ((ARCoachingOverlayView) -> Void)?
    /// The closure to call when the coaching overlay view deactivates.
    private(set) var onCoachingOverlayDeactivateAction: ((ARCoachingOverlayView) -> Void)?
    /// The closure to call when the user taps the coaching overlay view's Start Over button.
    private(set) var onCoachingOverlayRequestSessionResetAction: ((ARCoachingOverlayView) -> Void)?
    
    /// The data source for an AR session.
    var sessionProvider: ARSessionProviding?
    /// The goal for the coaching overlay.
    var goal: ARCoachingOverlayView.Goal
    /// A Boolean value that indicates if coaching is in progress.
    var active: Bool = false
    
    /// Controls whether the coaching is in progress.
    /// - Parameter active: A Boolean value indicating if coaching is in progress.
    /// - Returns: The `ARCoachingOverlay`.
    func active(_ active: Bool) -> Self {
        var view = self
        view.active = active
        return view
    }
    
    /// Sets the closure to call when the coaching overlay view activates.
    func onCoachingOverlayActivate(
        perform action: @escaping (ARCoachingOverlayView) -> Void
    ) -> Self {
        var view = self
        view.onCoachingOverlayActivateAction = action
        return view
    }
    
    /// Sets the closure to call when the coaching experience is completely deactivated.
    func onCoachingOverlayDeactivate(
        perform action: @escaping (ARCoachingOverlayView) -> Void
    ) -> Self {
        var view = self
        view.onCoachingOverlayDeactivateAction = action
        return view
    }
    
    /// Sets the closure to call when the user taps the coaching overlay view's Start Over button
    /// while the session is relocalizing.
    func onCoachingOverlayRequestSessionReset(
        perform action: @escaping (ARCoachingOverlayView) -> Void
    ) -> Self {
        var view = self
        view.onCoachingOverlayRequestSessionResetAction = action
        return view
    }
    
    /// Sets the AR session data source for the coaching overlay.
    /// - Parameter sessionProvider: The AR session data source.
    /// - Returns: The `ARCoachingOverlay`.
    func sessionProvider(_ sessionProvider: ARSessionProviding) -> Self {
        var view = self
        view.sessionProvider = sessionProvider
        return view
    }
}

extension ARCoachingOverlay: UIViewRepresentable {
    func makeUIView(context: Context) -> ARCoachingOverlayView {
        let view = ARCoachingOverlayView()
        view.delegate = context.coordinator
        view.activatesAutomatically = true
        return view
    }
    
    func updateUIView(_ uiView: ARCoachingOverlayView, context: Context) {
        uiView.sessionProvider = sessionProvider
        uiView.goal = goal
        uiView.setActive(active, animated: true)
        context.coordinator.onCoachingOverlayActivateAction = onCoachingOverlayActivateAction
        context.coordinator.onCoachingOverlayDeactivateAction = onCoachingOverlayDeactivateAction
        context.coordinator.onCoachingOverlayRequestSessionResetAction = onCoachingOverlayRequestSessionResetAction
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

extension ARCoachingOverlay {
    class Coordinator: NSObject, ARCoachingOverlayViewDelegate {
        var onCoachingOverlayActivateAction: ((ARCoachingOverlayView) -> Void)?
        var onCoachingOverlayDeactivateAction: ((ARCoachingOverlayView) -> Void)?
        var onCoachingOverlayRequestSessionResetAction: ((ARCoachingOverlayView) -> Void)?
        
        func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
            onCoachingOverlayActivateAction?(coachingOverlayView)
        }
        
        func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
            onCoachingOverlayDeactivateAction?(coachingOverlayView)
        }
        
        func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
            onCoachingOverlayRequestSessionResetAction?(coachingOverlayView)
        }
    }
}
#endif
