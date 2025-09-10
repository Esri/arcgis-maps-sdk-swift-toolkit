func signOut() {
    Task {
        await ArcGISEnvironment.authenticationManager.signOut()
    }
}
