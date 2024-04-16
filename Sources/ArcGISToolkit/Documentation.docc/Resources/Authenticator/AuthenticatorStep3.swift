***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***
struct AuthenticationApp: App {
***REMOVED***@StateObject private var authenticator = Authenticator()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***HomeView()
***REMOVED******REMOVED******REMOVED******REMOVED***.authenticator(authenticator)
***REMOVED******REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await ArcGISEnvironment.authenticationManager.setupPersistentCredentialStorage(access: .whenUnlockedThisDeviceOnly)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
