// Copyright 2023 Esri.

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

/// A view that is able to update a binding to an interface orientation.
/// This view will detect and report the interface orientation when the view is
/// in a window.
struct InterfaceOrientationDetector: UIViewControllerRepresentable {
    /// The binding to update when an interface orientation change is detected.
    let binding: Binding<InterfaceOrientation?>
    
    /// Creates an interface orientation detector view.
    init(interfaceOrientation: Binding<InterfaceOrientation?>) {
        binding = interfaceOrientation
    }
    
    func makeUIViewController(context: Context) -> InterfaceOrientationViewController {
        InterfaceOrientationViewController(interfaceOrientation: binding)
    }
    
    func updateUIViewController(_ uiView: InterfaceOrientationViewController, context: Context) {}
    
    final class InterfaceOrientationViewController: UIViewController {
        let binding: Binding<InterfaceOrientation?>
        
        init(interfaceOrientation: Binding<InterfaceOrientation?>) {
            binding = interfaceOrientation
            super.init(nibName: nil, bundle: nil)
            view.isUserInteractionEnabled = false
            view.isHidden = true
            view.isOpaque = false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.binding.wrappedValue = self.windowInterfaceOrientation
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            // According to the Apple documentation, this is the new way to be notified when the
            // interface orientation changes.
            // Also, a similar solution is on SO here: https://stackoverflow.com/a/60577486/1687195
            
            super.viewWillTransition(to: size, with: coordinator)
            
            coordinator.animate { _ in
                self.binding.wrappedValue = self.windowInterfaceOrientation
            }
        }
        
        /// The interface orientation of the window that this view is contained in.
        var windowInterfaceOrientation: InterfaceOrientation? {
            if let orientation = view.window?.windowScene?.interfaceOrientation {
                return InterfaceOrientation(orientation)
            } else {
                return nil
            }
        }
    }
}

private extension InterfaceOrientation {
    /// Creates an `InterfaceOrientation` from a `UIInterfaceOrientation`.
    init?(_ uiInterfaceOrientation: UIInterfaceOrientation) {
        switch uiInterfaceOrientation {
        case .unknown:
            return nil
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        @unknown default:
            assertionFailure("Unknown UIInterfaceOrientation")
            return nil
        }
    }
}
