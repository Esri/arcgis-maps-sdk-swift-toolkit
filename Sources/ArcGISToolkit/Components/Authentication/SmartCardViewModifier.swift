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
***REMOVED***

***REMOVED***/ A view modifier that prompts the alerts for smart card.
struct SmartCardViewModifier: ViewModifier {
***REMOVED******REMOVED***/ The authenticator.
***REMOVED***let authenticator: Authenticator
***REMOVED***
***REMOVED******REMOVED***/ The smart card manager.
***REMOVED***@ObservedObject var smartCardManager: SmartCardManager
***REMOVED***
***REMOVED******REMOVED***/ Creates smart card view modifier with given authenticator.
***REMOVED******REMOVED***/ - Parameter authenticator: The authenticator.
***REMOVED***init(authenticator: Authenticator) {
***REMOVED******REMOVED***self.authenticator = authenticator
***REMOVED******REMOVED***self.smartCardManager = authenticator.smartCardManager
***REMOVED***
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.promptDisconnectedCard(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $smartCardManager.isCardDisconnected,
***REMOVED******REMOVED******REMOVED******REMOVED***authenticator: authenticator
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.promptDifferentCardConnected(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $smartCardManager.isDifferentCardConnected,
***REMOVED******REMOVED******REMOVED******REMOVED***authenticator: authenticator
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays an alert to the user to let them know that the smart card is disconnected.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A binding to a Boolean value that determines whether to present an alert.
***REMOVED******REMOVED***/   - authenticator: The authenticator.
***REMOVED***@MainActor @ViewBuilder func promptDisconnectedCard(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***authenticator: Authenticator
***REMOVED***) -> some View {
***REMOVED******REMOVED***alert(
***REMOVED******REMOVED******REMOVED***Text("Smart Card Disconnected", bundle: .toolkitModule),
***REMOVED******REMOVED******REMOVED***isPresented: isPresented
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await authenticator.signOutAction()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Sign Out", bundle: .toolkitModule)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***print("Continue")
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Continue", bundle: .toolkitModule)
***REMOVED******REMOVED***
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"Connect a smart card and continue or sign out to access a different account.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays a prompt to the user to let them know that the smart card is disconnected.
***REMOVED******REMOVED***/ - Parameters: isPresented: A Boolean value indicating if the view is presented.
***REMOVED***@MainActor @ViewBuilder func promptDifferentCardConnected(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***authenticator: Authenticator
***REMOVED***) -> some View {
***REMOVED******REMOVED***alert(
***REMOVED******REMOVED******REMOVED***Text("Different Card Connected", bundle: .toolkitModule),
***REMOVED******REMOVED******REMOVED***isPresented: isPresented
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await authenticator.signOutAction()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Sign Out", bundle: .toolkitModule)
***REMOVED******REMOVED***
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED***"You must sign out to access a different account.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

