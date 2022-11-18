#  FloorFilter

The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building in your application. It allows you to filter down the floor plan data displayed in your geo view to a site, a building in the site, or a floor in the building. 

The ArcGIS Maps SDK currently supports filtering a 2D floor aware map based on the sites, buildings, or levels in the map.

|iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png)|

### Behavior:

When the Site button is tapped, a prompt opens so the user can select a site and then a facility. After selecting a site and facility, a list of levels is displayed either above or below the site button.

### Usage

```swift
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloorFilterExampleView.swift](../../Examples/Examples/FloorFilterExampleView.swift) in the project.
