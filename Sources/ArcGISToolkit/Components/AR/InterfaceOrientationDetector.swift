***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ A view that is able to update a binding to an interface orientation.
***REMOVED***/ This view will detect and report the interface orientation when the view is
***REMOVED***/ in a window.
struct InterfaceOrientationDetector: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The binding to update when an interface orientation change is detected.
***REMOVED***let binding: Binding<InterfaceOrientation?>
***REMOVED***
***REMOVED******REMOVED***/ Creates an interface orientation detector view.
***REMOVED***init(interfaceOrientation: Binding<InterfaceOrientation?>) {
***REMOVED******REMOVED***binding = interfaceOrientation
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> InterfaceOrientationViewController {
***REMOVED******REMOVED***InterfaceOrientationViewController(interfaceOrientation: binding)
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiView: InterfaceOrientationViewController, context: Context) {***REMOVED***
***REMOVED***
***REMOVED***final class InterfaceOrientationViewController: UIViewController {
***REMOVED******REMOVED***let binding: Binding<InterfaceOrientation?>
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(interfaceOrientation: Binding<InterfaceOrientation?>) {
***REMOVED******REMOVED******REMOVED***binding = interfaceOrientation
***REMOVED******REMOVED******REMOVED***super.init(nibName: nil, bundle: nil)
***REMOVED******REMOVED******REMOVED***view.isUserInteractionEnabled = false
***REMOVED******REMOVED******REMOVED***view.isHidden = true
***REMOVED******REMOVED******REMOVED***view.isOpaque = false
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***required init?(coder: NSCoder) {
***REMOVED******REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***override func viewDidAppear(_ animated: Bool) {
***REMOVED******REMOVED******REMOVED***super.viewDidAppear(animated)
***REMOVED******REMOVED******REMOVED***self.binding.wrappedValue = self.windowInterfaceOrientation
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
***REMOVED******REMOVED******REMOVED******REMOVED*** According to the Apple documentation, this is the new way to be notified when the
***REMOVED******REMOVED******REMOVED******REMOVED*** interface orientation changes.
***REMOVED******REMOVED******REMOVED******REMOVED*** Also, a similar solution is on SO here: https:***REMOVED***stackoverflow.com/a/60577486/1687195
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***super.viewWillTransition(to: size, with: coordinator)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***coordinator.animate { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***self.binding.wrappedValue = self.windowInterfaceOrientation
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The interface orientation of the window that this view is contained in.
***REMOVED******REMOVED***var windowInterfaceOrientation: InterfaceOrientation? {
***REMOVED******REMOVED******REMOVED***let x = view.window?.windowScene?.interfaceOrientation
***REMOVED******REMOVED******REMOVED***return x.map { InterfaceOrientation($0) ***REMOVED*** ?? nil
***REMOVED***
***REMOVED***
***REMOVED***

private extension InterfaceOrientation {
***REMOVED******REMOVED***/ Creates an `InterfaceOrientation` from a `UIInterfaceOrientation`.
***REMOVED***init?(_ uiInterfaceOrientation: UIInterfaceOrientation) {
***REMOVED******REMOVED***switch uiInterfaceOrientation {
***REMOVED******REMOVED***case .unknown:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case .portrait:
***REMOVED******REMOVED******REMOVED***self = .portrait
***REMOVED******REMOVED***case .portraitUpsideDown:
***REMOVED******REMOVED******REMOVED***self = .portraitUpsideDown
***REMOVED******REMOVED***case .landscapeLeft:
***REMOVED******REMOVED******REMOVED***self = .landscapeRight
***REMOVED******REMOVED***case .landscapeRight:
***REMOVED******REMOVED******REMOVED***self = .landscapeLeft
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***assertionFailure("Unknown UIInterfaceOrientation")
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
