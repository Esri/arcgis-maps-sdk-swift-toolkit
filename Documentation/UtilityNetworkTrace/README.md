# UtilityNetworkTrace

`UtilityNetworkTrace` runs traces on a webmap published with a utility network and trace configurations.

|iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204343568-a236ae0d-6b70-4175-a70c-41c902123ea1.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204344567-c86b3a49-6109-4333-8993-7fdc74f2b35d.png)|

## Features

The utility network trace tool displays a list of named trace configurations defined for utility networks in a web map. It enables users to add starting points and perform trace analysis from the selected named trace configuration.

A named trace configuration defined for a utility network in a webmap comprises the parameters used for a utility network trace.

## Key properties

`UtilityNetworkTrace` has the following initializer:

```swift
***REMOVED******REMOVED***/ A graphical interface to run pre-configured traces on a map's utility networks.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - activeDetent: The current detent of the floating panel.
***REMOVED******REMOVED***/   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
***REMOVED******REMOVED***/   - map: The map containing the utility network(s).
***REMOVED******REMOVED***/   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
***REMOVED******REMOVED***/   - screenPoint: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points.
***REMOVED***public init(
***REMOVED******REMOVED***graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***mapPoint: Binding<Point?>,
***REMOVED******REMOVED***screenPoint: Binding<CGPoint?>,
***REMOVED******REMOVED***mapViewProxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
***REMOVED***)
```

`UtilityNetworkTrace` the following instance method:

```swift
***REMOVED******REMOVED***/ Sets the active detent for a hosting floating panel.
***REMOVED******REMOVED***/ - Parameter detent: A binding to a value that determines the height of a hosting
***REMOVED******REMOVED***/ floating panel.
***REMOVED******REMOVED***/ - Returns: A trace tool that automatically sets and responds to detent values to improve user
***REMOVED******REMOVED***/ experience.
***REMOVED***public func floatingPanelDetent(_ detent: Binding<FloatingPanelDetent>) -> UtilityNetworkTrace
```

## Behavior:

The tool allows users to:
 - Choose between multiple networks (if more than one is defined in a webmap) .
 - Choose between named trace configurations:
 
 ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204346359-419b0056-3a30-4120-9b47-c68513abde42.png)
 
 - Add trace starting points either programmatically or by tapping on a map view, then use the inspection view to narrow the selection:
 
 ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204346273-38374067-a0b8-4db4-8e40-62b38e1603c8.png)

 - View trace results:
 
 |iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204343941-91775a25-8dc0-4866-8273-0d4bfaa91aeb.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204344435-173fbf34-59d6-4a0f-84bf-30ed5de3572e.png)|

 - Run multiple trace scenarios, then use color and name to compare results:
 
 ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/204346039-038ba4fa-201a-428c-ae84-be8f10c91cf7.png)

 - See user-friendly warnings to help avoid common mistakes, including specifying too many starting points or running the same trace configuration multiple times.

## Usage

```swift
UtilityNetworkTrace(
***REMOVED***graphicsOverlay: $resultGraphicsOverlay,
***REMOVED***map: map,
***REMOVED***mapPoint: $mapPoint,
***REMOVED***viewPoint: $viewPoint,
***REMOVED***mapViewProxy: $mapViewProxy,
***REMOVED***viewpoint: $viewpoint
)
```

To see the `UtilityNetworkTrace` in action, check out the [Examples](../../Examples) and refer to [UtilityNetworkTraceExampleView.swift](../../Examples/Examples/UtilityNetworkTraceExampleView.swift) in the project.
