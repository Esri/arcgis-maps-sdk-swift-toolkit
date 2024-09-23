***REMOVED*** Copyright 2022 Esri
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

import Foundation
***REMOVED***

extension View {
***REMOVED******REMOVED***/ Presents user experiences for collecting credentials from the user.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED******REMOVED***/   - fields: The fields shown in the view.
***REMOVED******REMOVED***/   - message: Descriptive text that provides more details about the reason for the alert.
***REMOVED******REMOVED***/   - title: The title of the alert.
***REMOVED******REMOVED***/   - cancelAction: The cancel action.
***REMOVED******REMOVED***/   - continueAction: The continue action.
***REMOVED***@ViewBuilder func credentialInput(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***fields: CredentialInputSheetView.Fields,
***REMOVED******REMOVED***message: String,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***cancelAction: CredentialInputSheetView.Action,
***REMOVED******REMOVED***continueAction: CredentialInputSheetView.Action
***REMOVED***) -> some View {
***REMOVED******REMOVED***modifier(
***REMOVED******REMOVED******REMOVED***CredentialInputModifier(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***fields: fields,
***REMOVED******REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: cancelAction,
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: continueAction
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

struct CredentialInputSheetView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED***.credentialInput(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: .constant(true),
***REMOVED******REMOVED******REMOVED******REMOVED***fields: .usernamePassword,
***REMOVED******REMOVED******REMOVED******REMOVED***message: "You must sign in to access 'arcgis.com'",
***REMOVED******REMOVED******REMOVED******REMOVED***title: "Authentication Required",
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "Cancel",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "Continue",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { username, password in
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that prompts for credentials.
struct CredentialInputModifier: ViewModifier {
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***var isPresented: Binding<Bool>
***REMOVED***
***REMOVED******REMOVED***/ The fields shown in the view.
***REMOVED***let fields: CredentialInputSheetView.Fields
***REMOVED***
***REMOVED******REMOVED***/ Descriptive text that provides more details about the reason for the alert.
***REMOVED***let message: String
***REMOVED***
***REMOVED******REMOVED***/ The title of the alert.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The cancel action.
***REMOVED***let cancelAction: CredentialInputSheetView.Action
***REMOVED***
***REMOVED******REMOVED***/ The continue action.
***REMOVED***let continueAction: CredentialInputSheetView.Action
***REMOVED***
***REMOVED***@ViewBuilder func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***CredentialInputSheetView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fields: fields,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***message: message,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: cancelAction,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueAction: continueAction
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct CredentialInputSheetView: View {
***REMOVED******REMOVED***/ The fields shown in the alert.
***REMOVED***private let fields: Fields
***REMOVED***
***REMOVED******REMOVED***/ Descriptive text that provides more details about the reason for the alert.
***REMOVED***private let message: String
***REMOVED***
***REMOVED******REMOVED***/ The title of the alert.
***REMOVED***private let title: String
***REMOVED***
***REMOVED******REMOVED***/ The cancel action.
***REMOVED***private let cancelAction: Action
***REMOVED***
***REMOVED******REMOVED***/ The continue action.
***REMOVED***private let continueAction: Action
***REMOVED***
***REMOVED******REMOVED***/ The value in the username field.
***REMOVED***@State private var username = ""
***REMOVED***
***REMOVED******REMOVED***/ The value in the password field.
***REMOVED***@State private var password = ""
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***private var isPresented: Binding<Bool>
***REMOVED***
***REMOVED***@FocusState private var usernameFieldIsFocused: Bool
***REMOVED***
***REMOVED***@FocusState private var passwordFieldIsFocused: Bool
***REMOVED***
***REMOVED******REMOVED***/ Creates the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED******REMOVED***/   - fields: The fields shown in the alert.
***REMOVED******REMOVED***/   - message: Descriptive text that provides more details about the reason for the alert.
***REMOVED******REMOVED***/   - title: The title of the alert.
***REMOVED******REMOVED***/   - cancelAction: The cancel action.
***REMOVED******REMOVED***/   - continueAction: The continue action.
***REMOVED***init(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***fields: Fields,
***REMOVED******REMOVED***message: String,
***REMOVED******REMOVED***title: String,
***REMOVED******REMOVED***cancelAction: Action,
***REMOVED******REMOVED***continueAction: Action
***REMOVED***) {
***REMOVED******REMOVED***self.isPresented = isPresented
***REMOVED******REMOVED***self.cancelAction = cancelAction
***REMOVED******REMOVED***self.continueAction = continueAction
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
***REMOVED******REMOVED******REMOVED***return !username.isEmpty && !password.isEmpty
***REMOVED******REMOVED***case .password:
***REMOVED******REMOVED******REMOVED***return !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var usernameTextField: some View {
***REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Username",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to a credential username."
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***text: $username
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.textInputAutocapitalization(.never)
***REMOVED******REMOVED***.autocorrectionDisabled(true)
***REMOVED******REMOVED***.textContentType(.username)
***REMOVED******REMOVED***.focused($usernameFieldIsFocused)
***REMOVED******REMOVED***.submitLabel(.next)
***REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED***passwordFieldIsFocused = true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var passwordTextField: some View {
***REMOVED******REMOVED***SecureField(
***REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Password",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label in reference to a credential password."
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***text: $password
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.submitLabel(.done)
***REMOVED******REMOVED***.textInputAutocapitalization(.never)
***REMOVED******REMOVED***.autocorrectionDisabled(true)
***REMOVED******REMOVED***.textContentType(.password)
***REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED***if isContinueEnabled {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction.handler(username, password)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.focused($passwordFieldIsFocused)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***GeometryReader { proxy in
***REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 8) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(message)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch fields {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .password:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***passwordTextField
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .usernamePassword:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***usernameTextField
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***passwordTextField
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** footer: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Adding the buttons to the footer or the
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** form will push the buttons to the bottom of
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** the sheet when we want the buttons
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** below the text fields.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelAction.handler("", "")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(cancelAction.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueAction.handler(username, password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(continueAction.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!isContinueEnabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.top)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED*** Set initial focus of text field.
***REMOVED******REMOVED******REMOVED***switch fields {
***REMOVED******REMOVED******REMOVED***case .usernamePassword:
***REMOVED******REMOVED******REMOVED******REMOVED***usernameFieldIsFocused = true
***REMOVED******REMOVED******REMOVED***case .password:
***REMOVED******REMOVED******REMOVED******REMOVED***passwordFieldIsFocused = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
extension CredentialInputSheetView {
***REMOVED******REMOVED***/ The fields shown in the alert. This determines if the view is intended to require either a username
***REMOVED******REMOVED***/ and password, or a password only.
***REMOVED***enum Fields {
***REMOVED******REMOVED******REMOVED***/ Indicates the view is intended to collect a password only.
***REMOVED******REMOVED***case password
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Indicates the view is intended to collect a username and password.
***REMOVED******REMOVED***case usernamePassword
***REMOVED***
***REMOVED***

extension CredentialInputSheetView {
***REMOVED******REMOVED***/ A configuration for an alert action.
***REMOVED***struct Action {
***REMOVED******REMOVED******REMOVED***/ The title of the action.
***REMOVED******REMOVED***let title: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ The block to execute when the action is triggered.
***REMOVED******REMOVED******REMOVED***/ The parameters are the username and the password.
***REMOVED******REMOVED***let handler: (String, String) -> Void
***REMOVED***
***REMOVED***
