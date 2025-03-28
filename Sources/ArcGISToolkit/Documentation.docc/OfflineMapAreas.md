# Offline Map Areas

The offline map areas toolkit components allow users to take web maps offline. 

Users can download map areas created ahead-of-time(preplanned) by the 
web map author, or they can create map areas on-demand by specifying an 
area of interest and level of detail. Map areas are downloaded to the app's 
Documents directory and can be used when the device is disconnected from 
the network. Users can get information about a map area such as its size and 
the geographic region it covers. They can also delete a downloaded map area to 
free up storage space on the device.

![An image of the OfflineMapAreasView component](OfflineMapAreasView)

The toolkit provides the following components to work with offline map areas:

- ``OfflineMapAreasView``: A view that allows users to download, view, and 
manage offline map areas from web maps. To see it in action, try out the [OfflineMapAreasExample](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/OfflineMapAreasExample) project.
- ``OfflineManager``: A utility class that manages offline map areas. Developers
can use the provided APIs to build their own UI to work with offline map areas.

Learn more about their usage in their respective documentation.

**Requirements**

The offline workflows can be configured to let long-running jobs continue to run
when the app is in the background or even terminated. These capabilities are 
provided by the ``OfflineManager`` component. To allow the offline manager to 
run jobs in the background, configure your app as follows:

- Set the [BGTaskSchedulerPermittedIdentifiers](https:***REMOVED***developer.apple.com/documentation/bundleresources/information-property-list/bgtaskschedulerpermittedidentifiers) in the app’s **info.plist** with "com.esri.ArcGISToolkit.jobManager.offlineManager.statusCheck".
- Set the [UIBackgroundModes](https:***REMOVED***developer.apple.com/documentation/bundleresources/information-property-list/uibackgroundmodes) in the app’s **info.plist** with "App downloads content from the network".
- In the project file's "Signing & Capabilities" tab, enable the
"Background Modes" capability and check "Background fetch".
- Add the `.offlineManager(preferredBackgroundStatusCheckSchedule:)` modifier to
the entry point of the app to configure the preferred schedule and perform
actions when there is an update when the app is in the background.

To learn more about using the offline map areas toolkit component see the <doc:OfflineMapAreasViewTutorial>.
