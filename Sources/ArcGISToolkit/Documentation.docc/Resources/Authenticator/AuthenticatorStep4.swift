func signOut() {
    Task {
        await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
        await ArcGISEnvironment.authenticationManager.invalidateIAPCredentials()
        await ArcGISEnvironment.authenticationManager.clearCredentialStores()
    }
}
