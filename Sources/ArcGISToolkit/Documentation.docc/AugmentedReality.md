# Augmented Reality

Augmented reality experiences are designed to "augment" the physical world with virtual 
content that respects real world scale, position, and orientation of a device. The following 
views overlay ArcGIS Scene imagery over a camera feed of the physical world to provide augmented 
reality experiences for common AR patterns including Flyover, TableTop, and World Scale AR.

**FlyoverSceneView**

`FlyoverSceneView` provides an augmented reality flyover experience that allows you to 
explore a scene using your device as a window into the virtual world. The experience begins
with the ArcGIS Scene's camera positioned over an area of interest. Walk around and reorient
the device to focus on specific content in the scene. To learn more about using the ``FlyoverSceneView`` see the <doc:FlyoverSceneViewTutorial>.

**TableTopSceneView**

`TableTopSceneView` provides an augmented reality table top experience where ArcGIS Scene content
is anchored to a physical surface. To learn more about using the ``TableTopSceneView`` see the <doc:TableTopSceneViewTutorial>.

**WorldScaleSceneView**

`WorldScaleSceneView` provides an augmented reality world scale experience where ArcGIS Scene content
is integrated with the real world. To learn more about using the ``WorldScaleSceneView`` see the <doc:WorldScaleSceneViewTutorial>.

###### Requirements
* Set the following properties in the app's **info.plist**:
    * [`Privacy - Camera Usage Description`](https://developer.apple.com/documentation/bundleresources/information_property_list/nscamerausagedescription) to request camera permissions.
    * [`Privacy - Location When In Use Usage Description`](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationwheninuseusagedescription) to request the user's location.
* To restrict your app to installing only on devices that support the following device capabilities, add the device capability to the required device capabilities section of the app's **info.plist**:
    * `arkit` to require support for ARKit.
    * `gps` to require GPS hardware for tracking locations.
    * `iphone-ipad-minimum-performance-a12` to require the performance and capabilities of A12 Bionic and later chips.
