# Authenticator

The `Authenticator` is a configurable object that handles authentication challenges.  It will display a user interface when network and ArcGIS authentication challenges occur.

![image](https://user-images.githubusercontent.com/3998072/203615041-c887d5e3-bb64-469a-a76b-126059329e92.png)

## Features

The `Authenticator` has a view modifier that will display a prompt when the `Authenticator` is asked to handle an authentication challenge.  This will handle many different types of authentication, for example:
  - ArcGIS authentication (token and OAuth)
  - Integrated Windows Authentication (IWA)
  - Client Certificate (PKI)

The `Authenticator` can be configured to support securely persisting credentials to the keychain.

## Key properties

`Authenticator` has the following view modifier:

```swift
    /// Presents user experiences for collecting network authentication credentials from the user.
    /// - Parameter authenticator: The authenticator for which credentials will be prompted.
    @ViewBuilder func authenticator(_ authenticator: Authenticator) -> some View
```

To securely store credentials in the keychain, use the following instance method on `Authenticator`:

```swift
    /// Sets up new credential stores that will be persisted to the keychain.
    /// - Remark: The credentials will be stored in the default access group of the keychain.
    /// You can find more information about what the default group would be here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - synchronizesWithiCloud: A Boolean value indicating whether the credentials are synchronized with iCloud.
    public func setupPersistentCredentialStorage(
        access: ArcGIS.KeychainAccess,
        synchronizesWithiCloud: Bool = false
    ) async throws
```

## Behavior:

The Authenticator view modifier will display an alert prompting the user for credentials. If credentials were persisted to the keychain, the Authenticator will use those instead of requiring the user to reenter credentials.

## Usage

### Basic usage for displaying the `Authenticator`.

This would typically go in your application's `App` struct.

```swift
init() {
    // Create an authenticator.
    authenticator = Authenticator(
        // If you want to use OAuth, uncomment this code:
        //oAuthConfigurations: [.arcgisDotCom]
    )
    // Set the challenge handler to be the authenticator we just created.
    ArcGISEnvironment.authenticationChallengeHandler = authenticator
}

var body: some SwiftUI.Scene {
    WindowGroup {
        HomeView()
            .authenticator(authenticator)
            .task {
                // Here we make the authenticator persistent, which means that it will synchronize
                // with the keychain for storing credentials.
                // It also means that a user can sign in without having to be prompted for
                // credentials. Once credentials are cleared from the stores ("sign-out"),
                // then the user will need to be prompted once again.
                try? await authenticator.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
            }
    }
}
```

To see the `Authenticator` in action, check out the [Authentication Examples](../../AuthenticationExample) and refer to [AuthenticationApp.swift](../../AuthenticationExample/AuthenticationExample/AuthenticationApp.swift) in the project.
