# Authenticator

Displays a user interface when network and ArcGIS authentication challenges occur.

## Features

The Authenticator is a view modifier that will cause a prompt when the Authenticator is asked to handle an authentication challenge.  This will handle many different types of authentication, for example:
  - ArcGIS authentication (token and OAuth)
  - Integrated Windows Authentication (IWA)
  - Client Certificate (PKI)

The Authenticator can be configured to support securely persisting credentials to the keychain.

## Behavior:

The Authenticator view modifier will display an alert or a full screen modal view to prompt the user for credentials.

## Usage

```swift
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Create an authenticator.
***REMOVED******REMOVED***authenticator = Authenticator(
***REMOVED******REMOVED******REMOVED******REMOVED*** If you want to use OAuth, uncomment this code:
***REMOVED******REMOVED******REMOVED******REMOVED***oAuthConfigurations: [.arcgisDotCom]
***REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED*** Set the challenge handler to be the authenticator we just created.
***REMOVED******REMOVED***ArcGISEnvironment.authenticationChallengeHandler = authenticator
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***HomeView()
***REMOVED******REMOVED******REMOVED******REMOVED***.authenticator(authenticator)
***REMOVED******REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Here we make the authenticator persistent, which means that it will synchronize
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** with the keychain for storing credentials.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** It also means that a user can sign in without having to be prompted for
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** credentials. Once credentials are cleared from the stores ("sign-out"),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** then the user will need to be prompted once again.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await authenticator.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
```

To see the `Authenticator` in action, check out the [Authentication Examples](../../AuthenticationExample) and refer to [AuthenticationApp.swift](../../AuthenticationExample/AuthenticationExample/AuthenticationApp.swift) in the project.
