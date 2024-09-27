***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import AVFoundation
***REMOVED***

***REMOVED***/ Performs camera authorization request handling.
***REMOVED***/
***REMOVED***/ Ensures that access is granted before launching the system camera.
@MainActor final class CameraRequester: ObservableObject {
***REMOVED***@Published var alertIsPresented = false
***REMOVED***
***REMOVED***var onAccessDenied: (() -> Void)?
***REMOVED***
***REMOVED***func request(onAccessGranted: @escaping () -> Void, onAccessDenied: @escaping () -> Void) {
***REMOVED******REMOVED***self.onAccessDenied = onAccessDenied
***REMOVED******REMOVED***switch AVCaptureDevice.authorizationStatus(for: .video) {
***REMOVED******REMOVED***case .authorized:
***REMOVED******REMOVED******REMOVED***onAccessGranted()
***REMOVED******REMOVED***case .notDetermined:
***REMOVED******REMOVED******REMOVED***AVCaptureDevice.requestAccess(for: .video) { granted in
***REMOVED******REMOVED******REMOVED******REMOVED***if granted {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onAccessGranted()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.alertIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***alertIsPresented = true
***REMOVED***
***REMOVED***
***REMOVED***

private struct CameraRequesterModifier: ViewModifier {
***REMOVED***@ObservedObject var requester: CameraRequester
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.alert(cameraAccessAlertTitle, isPresented: $requester.alertIsPresented) {
#if !targetEnvironment(macCatalyst)
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.settings) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) ***REMOVED***
***REMOVED******REMOVED******REMOVED***
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.cancel, role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***requester.onAccessDenied?()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(cameraAccessAlertMessage)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension View {
***REMOVED***func cameraRequester(_ requester: CameraRequester) -> some View {
***REMOVED******REMOVED***modifier(CameraRequesterModifier(requester: requester))
***REMOVED***
***REMOVED***

private extension CameraRequesterModifier {
***REMOVED******REMOVED***/ A message for an alert requesting camera access.
***REMOVED***var cameraAccessAlertMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Please enable camera access in settings.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A message for an alert requesting camera access."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A title for an alert that camera access is disabled.
***REMOVED***var cameraAccessAlertTitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Camera access is disabled",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A title for an alert that camera access is disabled."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
