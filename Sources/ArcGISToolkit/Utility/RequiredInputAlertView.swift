***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***

***REMOVED***/ A view that prompts a user to login with a username and password.
***REMOVED***/
***REMOVED***/ Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
struct RequiredInputAlertView: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***@Binding private var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State var fieldOne = ""
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State var fieldTwo = ""
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private let usage: Usage
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private let title: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private let message: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private let cancelConfiguration: ActionConfiguration
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***private let continueConfiguration: ActionConfiguration
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: <#isPresented description#>
***REMOVED******REMOVED***/   - message: <#message description#>
***REMOVED******REMOVED***/   - title: <#title description#>
***REMOVED******REMOVED***/   - usage: <#usage description#>
***REMOVED******REMOVED***/   - cancelConfiguration: <#cancelConfiguration description#>
***REMOVED******REMOVED***/   - continueConfiguration: <#continueConfiguration description#>
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***message: String,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***usage: Usage,
***REMOVED******REMOVED***cancelConfiguration: ActionConfiguration,
***REMOVED******REMOVED***continueConfiguration: ActionConfiguration
***REMOVED***) {
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.message = message
***REMOVED******REMOVED***self.title = title
***REMOVED******REMOVED***self.usage = usage
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.cancelConfiguration = cancelConfiguration
***REMOVED******REMOVED***self.continueConfiguration = continueConfiguration
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***var isContinueEnabled: Bool {
***REMOVED******REMOVED***switch usage {
***REMOVED******REMOVED***case .identityAndPassword:
***REMOVED******REMOVED******REMOVED***return !fieldOne.isEmpty && !fieldTwo.isEmpty
***REMOVED******REMOVED***case .passwordOnly:
***REMOVED******REMOVED******REMOVED***return !fieldTwo.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***/ - Parameter context: <#context description#>
***REMOVED******REMOVED***/ - Returns: <#description#>
***REMOVED***func makeAlertController(context: Context) -> UIAlertController {
***REMOVED******REMOVED***let uiAlertController = UIAlertController(
***REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED***preferredStyle: .alert
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cancelAction = UIAlertAction(title: cancelConfiguration.title, style: .cancel) { _ in
***REMOVED******REMOVED******REMOVED***cancelConfiguration.handler(fieldOne, fieldTwo)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let continueAction = UIAlertAction(title: continueConfiguration.title, style: .default) { _ in
***REMOVED******REMOVED******REMOVED***continueConfiguration.handler(fieldOne, fieldTwo)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if usage == .identityAndPassword {
***REMOVED******REMOVED******REMOVED***uiAlertController.addTextField { textField in
***REMOVED******REMOVED******REMOVED******REMOVED***textField.addAction(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIAction { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fieldOne = textField.text ?? ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueAction.isEnabled = isContinueEnabled
***REMOVED******REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: .editingChanged
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***textField.autocapitalizationType = .none
***REMOVED******REMOVED******REMOVED******REMOVED***textField.autocorrectionType = .no
***REMOVED******REMOVED******REMOVED******REMOVED***textField.placeholder = "Username"
***REMOVED******REMOVED******REMOVED******REMOVED***textField.returnKeyType = .next
***REMOVED******REMOVED******REMOVED******REMOVED***textField.textContentType = .username
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addTextField { textField in
***REMOVED******REMOVED******REMOVED***textField.addAction(
***REMOVED******REMOVED******REMOVED******REMOVED***UIAction { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fieldTwo = textField.text ?? ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueAction.isEnabled = isContinueEnabled
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***for: .editingChanged
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***textField.autocapitalizationType = .none
***REMOVED******REMOVED******REMOVED***textField.autocorrectionType = .no
***REMOVED******REMOVED******REMOVED***textField.delegate = context.coordinator
***REMOVED******REMOVED******REMOVED***textField.isSecureTextEntry = true
***REMOVED******REMOVED******REMOVED***textField.placeholder = "Password"
***REMOVED******REMOVED******REMOVED***textField.returnKeyType = .go
***REMOVED******REMOVED******REMOVED***textField.textContentType = .password
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelAction.isEnabled = true
***REMOVED******REMOVED***continueAction.isEnabled = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addAction(cancelAction)
***REMOVED******REMOVED***uiAlertController.addAction(continueAction)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return uiAlertController
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(self)
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> some UIViewController {
***REMOVED******REMOVED***return UIViewController()
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(
***REMOVED******REMOVED***_ uiViewController: UIViewControllerType,
***REMOVED******REMOVED***context: Context
***REMOVED***) {
***REMOVED******REMOVED***guard isPresented else { return ***REMOVED***
***REMOVED******REMOVED***let alertController = makeAlertController(context: context)
***REMOVED******REMOVED******REMOVED*** On a physical iOS 16 device, without the following delay, the
***REMOVED******REMOVED******REMOVED*** presentation fails and an error is thrown.
***REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
***REMOVED******REMOVED******REMOVED***uiViewController.present(alertController, animated: true) {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension RequiredInputAlertView {
***REMOVED******REMOVED***/ The coordinator for the login view that acts as a delegate to the underlying
***REMOVED******REMOVED***/ `UIAlertViewController`.
***REMOVED***final class Coordinator: NSObject, UITextFieldDelegate {
***REMOVED******REMOVED******REMOVED***/ The view that owns this coordinator.
***REMOVED******REMOVED***let parent: RequiredInputAlertView
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates the coordinator.
***REMOVED******REMOVED******REMOVED***/ - Parameter parent: The view that owns this coordinator.
***REMOVED******REMOVED***init(_ parent: RequiredInputAlertView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textFieldShouldReturn(_ textField: UITextField) -> Bool {
***REMOVED******REMOVED******REMOVED***guard !parent.fieldTwo.isEmpty else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***parent.continueConfiguration.handler(parent.fieldOne, parent.fieldTwo)
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED***

extension RequiredInputAlertView {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***struct ActionConfiguration {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let handler: (String, String) -> Void
***REMOVED***
***REMOVED***

extension RequiredInputAlertView {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***enum Usage {
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED***case identityAndPassword
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED***case passwordOnly
***REMOVED***
***REMOVED***
