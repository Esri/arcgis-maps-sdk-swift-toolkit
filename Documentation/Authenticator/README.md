# Authenticator

The `Authenticator` is a configurable object that handles authentication challenges. It will display a user interface when network and ArcGIS authentication challenges occur.

![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203615041-c887d5e3-bb64-469a-a76b-126059329e92.png)

## Features

The `Authenticator` has a view modifier that will display a prompt when the `Authenticator` is asked to handle an authentication challenge. This will handle many different types of authentication, for example:
  - ArcGIS authentication (token and OAuth)
  - Integrated Windows Authentication (IWA)
  - Client Certificate (PKI)

The `Authenticator` can be configured to support securely persisting credentials to the keychain.

## Key properties

`Authenticator` has the following view modifier:

```swift
***REMOVED******REMOVED***/ Presents user experiences for collecting network authentication credentials from the user.
***REMOVED******REMOVED***/ - Parameter authenticator: The authenticator for which credentials will be prompted.
***REMOVED***@ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View
```

To securely store credentials in the keychain, use the following extension method of `AuthenticationManager`:

```swift
***REMOVED******REMOVED***/ Sets up new credential stores that will be persisted to the keychain.
***REMOVED******REMOVED***/ - Remark: The credentials will be stored in the default access group of the keychain.
***REMOVED******REMOVED***/ You can find more information about what the default group would be here:
***REMOVED******REMOVED***/ https:***REMOVED***developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - access: When the credentials stored in the keychain can be accessed.
***REMOVED******REMOVED***/   - synchronizesWithiCloud: A Boolean value indicating whether the credentials are synchronized with iCloud.
***REMOVED***public func setupPersistentCredentialStorage(
***REMOVED******REMOVED***access: ArcGIS.KeychainAccess,
***REMOVED******REMOVED***synchronizesWithiCloud: Bool = false
***REMOVED***) async throws
```

During sign-out, use the following extension methods of `AuthenticationManager`:

```swift
***REMOVED******REMOVED***/ Revokes tokens of OAuth user credentials.
***REMOVED***func revokeOAuthTokens() async

***REMOVED******REMOVED***/ Clears all ArcGIS and network credentials from the respective stores.
***REMOVED******REMOVED***/ Note: This sets up new `URLSessions` so that removed network credentials are respected
***REMOVED******REMOVED***/ right away.
***REMOVED***func clearCredentialStores() async
```

## Behavior:

The Authenticator view modifier will display an alert prompting the user for credentials. If credentials were persisted to the keychain, the Authenticator will use those instead of requiring the user to reenter credentials.

## Usage

### Basic usage for displaying the `Authenticator`.

This would typically go in your application's `App` struct.

```swift
init() {
***REMOVED******REMOVED*** Create an authenticator.
***REMOVED***authenticator = Authenticator(
***REMOVED******REMOVED******REMOVED*** If you want to use OAuth, uncomment this code:
***REMOVED******REMOVED******REMOVED***oAuthConfigurations: [.arcgisDotCom]
***REMOVED***)
***REMOVED******REMOVED*** Sets authenticator as ArcGIS and Network challenge handlers to handle authentication
***REMOVED******REMOVED*** challenges.
***REMOVED***ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED***

var body: some SwiftUI.Scene {
***REMOVED***WindowGroup {
***REMOVED******REMOVED***HomeView()
***REMOVED******REMOVED******REMOVED***.authenticator(authenticator)
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Here we setup credential stores to be persistent, which means that it will
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** synchronize with the keychain for storing credentials.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** It also means that a user can sign in without having to be prompted for
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** credentials. Once credentials are cleared from the stores ("sign-out"),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** then the user will need to be prompted once again.
***REMOVED******REMOVED******REMOVED******REMOVED***try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
```

To see the `Authenticator` in action, check out the [Authentication Examples](../../AuthenticationExample) and refer to [AuthenticationApp.swift](../../AuthenticationExample/AuthenticationExample/AuthenticationApp.swift) in the project.
