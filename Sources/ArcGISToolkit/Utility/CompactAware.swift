***REMOVED*** Copyright 2023 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***

***REMOVED***/ A type that can be used to make a view responsive to horizontal and vertical size classes.
***REMOVED***/
***REMOVED***/ Use the `CompactAware` protocol to easily detect compact environments in views. Simply add two
***REMOVED***/ `@Environment` property wrappers for `.horizontalSizeClass` and `.verticalSizeClass` to
***REMOVED***/ conforming views and use ``isCompact`` where needed.
public protocol CompactAware {
***REMOVED***var horizontalSizeClass: UserInterfaceSizeClass? { get ***REMOVED***
***REMOVED***var verticalSizeClass: UserInterfaceSizeClass? { get ***REMOVED***
***REMOVED***

extension CompactAware {
***REMOVED******REMOVED***/ A Boolean value indicating if the view is in a compact environment.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - iPhone: `true` in vertical orientation and `false` otherwise.
***REMOVED******REMOVED***/ - iPad: `true` in multitasking mode at limited widths and `false` otherwise.
***REMOVED******REMOVED***/ - Mac Catalyst: Always `false`.
***REMOVED***public var isCompact: Bool {
***REMOVED******REMOVED***horizontalSizeClass == .compact && verticalSizeClass == .regular
***REMOVED***
***REMOVED***
