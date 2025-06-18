# Configure App Secrets

As a best-practice principle, our project conceals app secrets from source code by generating and compiling an `AppSecrets.swift` source code file at build time using a custom build rule. The same pattern can be applied to your app development as well.

This build rule looks for a secrets file stored in the toolkit's root directory, `/.secrets`.

Note: License strings are not required for development. When no license or an invalid license key is applied, an app will fall back to Developer Mode (which will display a watermark on the map and scene views). Apply the license strings when your app is ready for deployment.

1. Create a hidden secrets file in your project's root directory.

  ```sh
  touch .secrets
  ```

2. Add your **API Key** access token to the secrets file.

  ```sh
  echo ARCGIS_API_KEY_DEVELOPMENT=your-api-key >> .secrets
  ```

  > Replace 'your-license-key', 'your-extension-license-key' and 'your-api-key' with your keys.

Visit the developer's website to learn more about [Deployment](https://developers.arcgis.com/swift/license-and-deployment/) and [Security and authentication](https://developers.arcgis.com/documentation/security-and-authentication/).

To learn more about `masquerade`, consult the [documentation](https://github.com/Esri/data-collection-ios/tree/main/docs#masquerade) of Esri's Data Collection app.
