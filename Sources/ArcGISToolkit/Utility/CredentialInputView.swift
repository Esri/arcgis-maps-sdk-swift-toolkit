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

***REMOVED***/ A view that prompts a user to provide credentials. It can be configured to require either a username and
***REMOVED***/ password, or a password only.
***REMOVED***/
***REMOVED***/ The view is implemented as a wrapper for a UIKit `UIAlertController` because as of iOS 16,
***REMOVED***/ SwiftUI alerts don't support visible but disabled buttons.
struct CredentialInputView: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The cancel action.
***REMOVED***private let cancelAction: Action
***REMOVED***
***REMOVED******REMOVED***/ The continue action.
***REMOVED***private let continueAction: Action
***REMOVED***
***REMOVED******REMOVED***/ The value in the identity field.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This member is unused when usage is set to `Usage.passwordOnly`.
***REMOVED***@State private var identity = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***@Binding private var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ Descriptive text that provides more details about the reason for the alert.
***REMOVED***private let message: String
***REMOVED***
***REMOVED******REMOVED***/ The value in the password field.
***REMOVED***@State private var password = ""
***REMOVED***
***REMOVED******REMOVED***/ The title of the alert.
***REMOVED***private let title: String
***REMOVED***
***REMOVED******REMOVED***/ The fields shown in the alert.
***REMOVED***private let fields: Fields
***REMOVED***
***REMOVED******REMOVED***/ Creates the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED******REMOVED***/   - message: Descriptive text that provides more details about the reason for the alert.
***REMOVED******REMOVED***/   - title: The title of the alert.
***REMOVED******REMOVED***/   - fields: The fields shown in the alert.
***REMOVED******REMOVED***/   - cancelAction: The cancel action.
***REMOVED******REMOVED***/   - continueAction: The continue action.
***REMOVED***init(
***REMOVED******REMOVED***fields: Fields,
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***message: String,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***cancelAction: Action,
***REMOVED******REMOVED***continueAction: Action
***REMOVED***) {
***REMOVED******REMOVED***self.cancelAction = cancelAction
***REMOVED******REMOVED***self.continueAction = continueAction
***REMOVED******REMOVED***
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED******REMOVED***
***REMOVED******REMOVED***self.fields = fields
***REMOVED******REMOVED***self.message = message
***REMOVED******REMOVED***self.title = title
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the alert should allow the continue action to proceed.
***REMOVED***private var isContinueEnabled: Bool {
***REMOVED******REMOVED***switch fields {
***REMOVED******REMOVED***case .usernamePassword:
***REMOVED******REMOVED******REMOVED***return !identity.isEmpty && !password.isEmpty
***REMOVED******REMOVED***case .password:
***REMOVED******REMOVED******REMOVED***return !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates the alert controller.
***REMOVED******REMOVED***/ - Parameter context: A context structure containing information about the current state of the
***REMOVED******REMOVED***/ system.
***REMOVED******REMOVED***/ - Returns: The alert controller displayed to the user.
***REMOVED***private func makeAlertController(context: Context) -> UIAlertController {
***REMOVED******REMOVED***let uiAlertController = UIAlertController(
***REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED***preferredStyle: .alert
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let cancelUIAlertAction = UIAlertAction(
***REMOVED******REMOVED******REMOVED***title: cancelAction.title,
***REMOVED******REMOVED******REMOVED***style: .cancel
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***cancelAction.handler(identity, password)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let continueUIAlertAction = UIAlertAction(
***REMOVED******REMOVED******REMOVED***title: continueAction.title,
***REMOVED******REMOVED******REMOVED***style: .default
***REMOVED******REMOVED***) { _ in
***REMOVED******REMOVED******REMOVED***continueAction.handler(identity, password)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if fields == .usernamePassword {
***REMOVED******REMOVED******REMOVED***uiAlertController.addTextField { textField in
***REMOVED******REMOVED******REMOVED******REMOVED***textField.addAction(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIAction { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***identity = textField.text ?? ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueUIAlertAction.isEnabled = isContinueEnabled
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***password = textField.text ?? ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueUIAlertAction.isEnabled = isContinueEnabled
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***for: .editingChanged
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***textField.autocapitalizationType = .none
***REMOVED******REMOVED******REMOVED***textField.autocorrectionType = .no
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Add a coordinator to the password field so that the primary
***REMOVED******REMOVED******REMOVED******REMOVED*** keyboard action can be disabled when the field is empty.
***REMOVED******REMOVED******REMOVED***textField.delegate = context.coordinator
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***textField.isSecureTextEntry = true
***REMOVED******REMOVED******REMOVED***textField.placeholder = "Password"
***REMOVED******REMOVED******REMOVED***textField.returnKeyType = .go
***REMOVED******REMOVED******REMOVED***textField.textContentType = .password
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelUIAlertAction.isEnabled = true
***REMOVED******REMOVED***continueUIAlertAction.isEnabled = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addAction(cancelUIAlertAction)
***REMOVED******REMOVED***uiAlertController.addAction(continueUIAlertAction)
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
***REMOVED******REMOVED******REMOVED*** presentation fails and the following warning is logged: "Attempt to
***REMOVED******REMOVED******REMOVED*** present UIAlertController on UIViewController whose view is not in
***REMOVED******REMOVED******REMOVED*** the window hierarchy."
***REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
***REMOVED******REMOVED******REMOVED***uiViewController.present(alertController, animated: true) {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension CredentialInputView {
***REMOVED******REMOVED***/ The coordinator for the login view that acts as a delegate to the underlying
***REMOVED******REMOVED***/ `UIAlertViewController`.
***REMOVED***final class Coordinator: NSObject, UITextFieldDelegate {
***REMOVED******REMOVED******REMOVED***/ The view that owns this coordinator.
***REMOVED******REMOVED***let parent: CredentialInputView
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates the coordinator.
***REMOVED******REMOVED******REMOVED***/ - Parameter parent: The view that owns this coordinator.
***REMOVED******REMOVED***init(_ parent: CredentialInputView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textFieldShouldReturn(_ textField: UITextField) -> Bool {
***REMOVED******REMOVED******REMOVED***guard !parent.password.isEmpty else { return false ***REMOVED***
***REMOVED******REMOVED******REMOVED***parent.continueAction.handler(
***REMOVED******REMOVED******REMOVED******REMOVED***parent.identity,
***REMOVED******REMOVED******REMOVED******REMOVED***parent.password
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED***

extension CredentialInputView {
***REMOVED******REMOVED***/ A configuration for an alert action.
***REMOVED***struct Action {
***REMOVED******REMOVED******REMOVED***/ The title of the action.
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The block to execute when the action is triggered.
***REMOVED******REMOVED***let handler: (String, String) -> Void
***REMOVED***
***REMOVED***

extension CredentialInputView {
***REMOVED******REMOVED***/ The fields shown in the alert. This determines if the view is intended to require either a username
***REMOVED******REMOVED***/ and password, or a password only.
***REMOVED***enum Fields {
***REMOVED******REMOVED******REMOVED***/ Indicates the view is intended to collect a username and password.
***REMOVED******REMOVED***case usernamePassword
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates the view is intended to collect a password only.
***REMOVED******REMOVED***case password
***REMOVED***
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Presents user experiences for collecting credentials from the user.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - fields: The fields shown in the view.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED******REMOVED***/   - message: Descriptive text that provides more details about the reason for the alert.
***REMOVED******REMOVED***/   - title: The title of the alert.
***REMOVED******REMOVED***/   - cancelAction: The cancel action.
***REMOVED******REMOVED***/   - continueAction: The continue action.
***REMOVED***@ViewBuilder func credentialInput(
***REMOVED******REMOVED***fields: CredentialInputView.Fields,
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***message: String,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***cancelAction: CredentialInputView.Action,
***REMOVED******REMOVED***continueAction: CredentialInputView.Action
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***CredentialInputModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***fields: fields,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: cancelAction,
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: continueAction
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that prompts for credentials.
struct CredentialInputModifier: ViewModifier {
***REMOVED***
***REMOVED******REMOVED***/ The fields shown in the view.
***REMOVED***let fields: CredentialInputView.Fields
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ Descriptive text that provides more details about the reason for the alert.
***REMOVED***let message: String
***REMOVED***
***REMOVED******REMOVED***/ The title of the alert.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The cancel action.
***REMOVED***let cancelAction: CredentialInputView.Action
***REMOVED***
***REMOVED******REMOVED***/ The continue action.
***REMOVED***let continueAction: CredentialInputView.Action
***REMOVED***
***REMOVED***@ViewBuilder func body(content: Content) -> some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***CredentialInputView(
***REMOVED******REMOVED******REMOVED******REMOVED***fields: fields,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: cancelAction,
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: continueAction
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
