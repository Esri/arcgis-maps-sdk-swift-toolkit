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

***REMOVED***
struct AuthenticationApp: App {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***@State private var isSettingUp = true
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Create an authenticator.
***REMOVED******REMOVED***authenticator = Authenticator(
***REMOVED******REMOVED******REMOVED******REMOVED*** If you want to use OAuth, uncomment this code:
***REMOVED******REMOVED******REMOVED******REMOVED***oAuthUserConfigurations: [.arcgisDotCom]
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Sets authenticator as ArcGIS and Network challenge handlers to handle authentication
***REMOVED******REMOVED******REMOVED*** challenges.
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if isSettingUp {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HomeView()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** Using this view modifier will cause a prompt when the authenticator is asked
***REMOVED******REMOVED******REMOVED******REMOVED*** to handle an authentication challenge.
***REMOVED******REMOVED******REMOVED******REMOVED*** This will handle many different types of authentication, for example:
***REMOVED******REMOVED******REMOVED******REMOVED*** - ArcGIS authentication (token and OAuth)
***REMOVED******REMOVED******REMOVED******REMOVED*** - Integrated Windows Authentication (IWA)
***REMOVED******REMOVED******REMOVED******REMOVED*** - Client Certificate (PKI)
***REMOVED******REMOVED******REMOVED***.authenticator(authenticator)
***REMOVED******REMOVED******REMOVED***.environmentObject(authenticator)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***isSettingUp = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Here we setup credential stores to be persistent, which means that it will
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** synchronize with the keychain for storing credentials.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** It also means that a user can sign in without having to be prompted for
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** credentials. Once credentials are cleared from the stores ("sign-out"),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** then the user will need to be prompted once again.
***REMOVED******REMOVED******REMOVED******REMOVED***try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
***REMOVED******REMOVED******REMOVED******REMOVED***isSettingUp = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension OAuthUserConfiguration {
***REMOVED******REMOVED*** If you want to use OAuth, you can uncomment this code:
***REMOVED******REMOVED***static let arcgisDotCom = OAuthUserConfiguration(
***REMOVED******REMOVED******REMOVED***portalURL: .portal,
***REMOVED******REMOVED******REMOVED***clientID: "<#Your client ID goes here#>",
***REMOVED******REMOVED******REMOVED******REMOVED*** Note: You must have the same redirect URL used here
***REMOVED******REMOVED******REMOVED******REMOVED*** registered with your client ID.
***REMOVED******REMOVED******REMOVED******REMOVED*** The scheme of the redirect URL is also specified in the Info.plist file.
***REMOVED******REMOVED******REMOVED***redirectURL: URL(string: "authexample:***REMOVED***auth")!
***REMOVED******REMOVED***)
***REMOVED***

extension URL {
***REMOVED******REMOVED*** If you want to use your own portal, provide your own URL here:
***REMOVED***static let portal = URL(string: "https:***REMOVED***www.arcgis.com")!
***REMOVED***
