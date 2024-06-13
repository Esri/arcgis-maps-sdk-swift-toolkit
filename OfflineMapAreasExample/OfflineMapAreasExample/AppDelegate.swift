***REMOVED*** Copyright 2024 Esri
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

import UIKit
import UserNotifications

class AppDelegate: UIResponder {***REMOVED***

extension AppDelegate: UIApplicationDelegate {
***REMOVED***func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
***REMOVED******REMOVED***UNUserNotificationCenter.current().delegate = self
***REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***

extension AppDelegate: UNUserNotificationCenterDelegate {
***REMOVED***func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
***REMOVED******REMOVED******REMOVED*** Present banner notifications in app foreground.
***REMOVED******REMOVED***completionHandler([.banner])
***REMOVED***
***REMOVED***
