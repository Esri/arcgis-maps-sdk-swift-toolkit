# Augmented Reality

Augmented reality experiences are designed to "augment" the physical world with virtual 
content that respects real world scale, position, and orientation of a device. The following 
views overlay ArcGIS Scene imagery over a camera feed of the physical world to provide augmented 
reality experiences for common AR patterns including Flyover and TableTop AR.

**FlyoverSceneView**

`FlyoverSceneView` provides an augmented reality flyover experience that allows you to 
explore a scene using your device as a window into the virtual world. The experience begins
with the ArcGIS Scene's camera positioned over an area of interest. Walk around and reorient
the device to focus on specific content in the scene. To learn more about using the FlyoverSceneView see the 
 [FlyoverSceneView Tutorial](https://developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/flyoversceneviewtutorial).

**TableTopSceneView**

`TableTopSceneView` provides an augmented reality table top experience where ArcGIS Scene content
is anchored to a physical surface. To learn more about using the TableTopSceneView see the 
[TableTopSceneView Tutorial](https://developers.arcgis.com/swift/toolkit-api-reference/tutorials/arcgistoolkit/tabletopsceneviewtutorial).

###### Requirements
* Set the [`Privacy - Camera Usage Description`](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription) property in the app's **info.plist** to request camera permissions.
* To restrict your app to installing only on devices that support ARKit, add `arkit` to the required device capabilities section of the app's **info.plist**.
