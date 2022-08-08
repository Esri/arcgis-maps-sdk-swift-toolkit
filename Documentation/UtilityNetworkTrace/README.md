# UtilityNetworkTrace

`UtilityNetworkTrace` runs traces on a webmap published with a utility network and trace configurations.

## Features

The utility network trace tool displays a list of named trace configurations defined for utility networks in a web map. It enables users to add starting points and perform trace analysis from the selected named trace configuration.

A named trace configuration defined for a utility network in a webmap comprises the parameters used for a utility network trace.

## Behavior:

The tool allows users to:
 - Choose between multiple networks (if more than one is defined in a webmap) 
 - Choose between named trace configurations
 - Add trace starting points either programmatically or by tapping on a map view
 - View trace results

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
