***REMOVED***
***REMOVED***Toolkit
***REMOVED***

***REMOVED***
struct AuthenticationApp: App {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED***authenticator = Authenticator()
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***HomeView()
***REMOVED******REMOVED******REMOVED******REMOVED***.authenticator(authenticator)
***REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(authenticator)
***REMOVED***
***REMOVED***
***REMOVED***
