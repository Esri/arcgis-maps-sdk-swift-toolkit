func signOut() {
    Task {
        await ArcGISEnvironment.authenticationManager.revokeOAuthTokens()
        await ArcGISEnvironment.authenticationManager.clearCredentialStores()
    }
}
