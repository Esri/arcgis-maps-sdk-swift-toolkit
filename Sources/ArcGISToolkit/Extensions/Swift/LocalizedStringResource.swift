***REMOVED*** Copyright 2025 Esri
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

import Foundation

extension LocalizedStringResource.BundleDescription {
***REMOVED******REMOVED***/ The toolkit's bundle.
***REMOVED***static let toolkit: Self = .atURL(Bundle.toolkitModule.bundleURL)
***REMOVED***


extension LocalizedStringResource {
***REMOVED***static var downloaded: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Downloaded",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area is downloaded."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var downloadFailed: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Download failed",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area failed to download."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var downloading: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Downloading",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area is downloading."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var loading: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Loading",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area is loading."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var loadingFailed: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"Loading failed",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "The status text when a map area failed to load."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var noInternetConnectionErrorMessage: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"No Internet Connection",
***REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED***comment: "An error message explaining that there is no internet connection."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
