# Authenticator

Displays user interface when network and ArcGIS authentication challenges occur.

## Features

The Authenticator is a view modifier that will cause a prompt when the Authenticator is asked to handle an authentication challenge.  This will handle many different types of authentication, for example:
  - ArcGIS authentication (token and OAuth)
  - Integrated Windows Authentication (IWA)
  - Client Certificate (PKI)

The Authenticator can be configured to support securely persisting credentials to they keychain.

## Behavior:

The Authenticator view modifier will display an alert or a full screen modal view to prompt the user for credentials.

## Usage

```swift
    init() {
        // Create an authenticator.
        authenticator = Authenticator(
            // If you want to use OAuth, uncomment this code:
            //oAuthConfigurations: [.arcgisDotCom]
        )
        // Set the challenge handler to be the authenticator we just created.
        ArcGISRuntimeEnvironment.authenticationChallengeHandler = authenticator
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {     
            HomeView()
                .authenticator(authenticator)
                .task {
                    // Here we make the authenticator persistent, which means that it will synchronize
                    // with they keychain for storing credentials.
                    // It also means that a user can sign in without having to be prompted for
                    // credentials. Once credentials are cleared from the stores ("sign-out"),
                    // then the user will need to be prompted once again.
                    try? await authenticator.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
                }
        }
    }
```

To see the `Authenticator` in action, check out the [Authentication Examples](../../AuthenticationExample) and refer to [AuthenticationApp.swift](../../AuthenticationExample/AuthenticationExample/AuthenticationApp.swift) in the project.
