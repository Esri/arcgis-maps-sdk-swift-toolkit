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

***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***/ A view that displays the profile of a user.
@MainActor
struct ProfileView: View {
***REMOVED******REMOVED***/ The portal that the user is signed in to.
***REMOVED***let portal: Portal
***REMOVED***
***REMOVED******REMOVED***/ A Boolean indicating whether the user is signing out.
***REMOVED***@State private var isSigningOut = false
***REMOVED***
***REMOVED******REMOVED***/ The closure to call once the user has signed out.
***REMOVED***var signOutAction: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if let user = portal.user {
***REMOVED******REMOVED******REMOVED******REMOVED***UserView(user: user).padding()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***signOutButton
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***var signOutButton: some View {
***REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED***signOut()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***if isSigningOut {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Sign Out")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED***.disabled(isSigningOut)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Signs out from the portal and clears the credential stores.
***REMOVED***func signOut() {
***REMOVED******REMOVED***isSigningOut = true
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
***REMOVED******REMOVED******REMOVED***await ArcGISEnvironment.authenticationManager.clearCredentialStores()
***REMOVED******REMOVED******REMOVED***isSigningOut = false
***REMOVED******REMOVED******REMOVED***signOutAction()
***REMOVED***
***REMOVED***
***REMOVED***
