***REMOVED***
***REMOVED*** COPYRIGHT 1995-2022 ESRI
***REMOVED***
***REMOVED*** TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
***REMOVED*** Unpublished material - all rights reserved under the
***REMOVED*** Copyright Laws of the United States and applicable international
***REMOVED*** laws, treaties, and conventions.
***REMOVED***
***REMOVED*** For additional information, contact:
***REMOVED*** Environmental Systems Research Institute, Inc.
***REMOVED*** Attn: Contracts and Legal Services Department
***REMOVED*** 380 New York Street
***REMOVED*** Redlands, California, 92373
***REMOVED*** USA
***REMOVED***
***REMOVED*** email: contracts@esri.com
***REMOVED***

import Foundation

***REMOVED***/ An actor that provides access to the device keychain.
actor Keychain {
***REMOVED******REMOVED***/ The shared instance.
***REMOVED***static let shared = Keychain()
***REMOVED***
***REMOVED***private init() {***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates parameters for storing a generic password item in the keychain.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - identifier: The unique identifier for the item.
***REMOVED******REMOVED***/   - value: The data value of the item.
***REMOVED******REMOVED***/   - access: When the item can be accessed.
***REMOVED******REMOVED***/   - service: The associated service of the item.
***REMOVED******REMOVED***/   - label: A label for the item.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group that the item should be stored in.
***REMOVED******REMOVED***/   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
***REMOVED***static func makeStoreItemParameters(
***REMOVED******REMOVED***identifier: String,
***REMOVED******REMOVED***value: Data,
***REMOVED******REMOVED***access: KeychainAccess,
***REMOVED******REMOVED***service: String?,
***REMOVED******REMOVED***label: String?,
***REMOVED******REMOVED***groupIdentifier: String?,
***REMOVED******REMOVED***isSynchronizable: Bool
***REMOVED***) -> CFDictionary {
***REMOVED******REMOVED***var parameters = [CFString : Any]()
***REMOVED******REMOVED***parameters[kSecClass] = kSecClassGenericPassword
***REMOVED******REMOVED***parameters[kSecAttrAccount] = identifier
***REMOVED******REMOVED***if let service = service {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrService] = service
***REMOVED***
***REMOVED******REMOVED***if let label = label {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrLabel] = label
***REMOVED***
***REMOVED******REMOVED***parameters[kSecValueData] = value
***REMOVED******REMOVED***parameters[kSecAttrAccessible] = access.value
***REMOVED******REMOVED***parameters[kSecAttrAccessGroup] = groupIdentifier
***REMOVED******REMOVED***parameters[kSecAttrSynchronizable] = isSynchronizable
***REMOVED******REMOVED******REMOVED*** This is highly recommended to be set to true for all keychain operations.
***REMOVED******REMOVED******REMOVED*** This key helps to improve the portability of your code across platforms.
***REMOVED******REMOVED******REMOVED*** More information here: https:***REMOVED***developer.apple.com/documentation/security/ksecusedataprotectionkeychain
***REMOVED******REMOVED***parameters[kSecUseDataProtectionKeychain] = true
***REMOVED******REMOVED***return parameters as CFDictionary
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Stores a generic password item in the keychain.
***REMOVED******REMOVED***/ - Remark: If no group is specified then the item will be stored in the default group.
***REMOVED******REMOVED***/ To know more about what the default group would be you can find information about that here:
***REMOVED******REMOVED***/ https:***REMOVED***developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - identifier: The unique identifier for the item to be stored under.
***REMOVED******REMOVED***/   - value: The data value of the item.
***REMOVED******REMOVED***/   - access: When the item can be accessed.
***REMOVED******REMOVED***/   - service: The service that the item is associated with.
***REMOVED******REMOVED***/   - label: A label for the item.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group that the item should be stored in.
***REMOVED******REMOVED***/   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
***REMOVED***func storeItem(
***REMOVED******REMOVED***identifier: String,
***REMOVED******REMOVED***value: Data,
***REMOVED******REMOVED***access: KeychainAccess,
***REMOVED******REMOVED***service: URL? = nil,
***REMOVED******REMOVED***label: String? = nil,
***REMOVED******REMOVED***groupIdentifier: String? = nil,
***REMOVED******REMOVED***isSynchronizable: Bool = false
***REMOVED***) throws {
***REMOVED******REMOVED***try removeItem(withIdentifier: identifier)
***REMOVED******REMOVED***let parameters = Self.makeStoreItemParameters(
***REMOVED******REMOVED******REMOVED***identifier: identifier,
***REMOVED******REMOVED******REMOVED***value: value,
***REMOVED******REMOVED******REMOVED***access: access,
***REMOVED******REMOVED******REMOVED***service: service?.absoluteString,
***REMOVED******REMOVED******REMOVED***label: label,
***REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier,
***REMOVED******REMOVED******REMOVED***isSynchronizable: isSynchronizable
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let status = SecItemAdd(parameters, nil)
***REMOVED******REMOVED***guard status == errSecSuccess else {
***REMOVED******REMOVED******REMOVED***throw KeychainError(status: status)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates parameters for retrieving items from the keychain.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - identifier: The identifier of the item to retrieve.
***REMOVED******REMOVED***/   - label: The label of the item to retrieve.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
***REMOVED******REMOVED***/   search will not be limited to a particular group.
***REMOVED******REMOVED***/   - limitOne: A value indicating if only a single result should be returned.
***REMOVED***static func makeGetItemsParameters(
***REMOVED******REMOVED***identifier: String?,
***REMOVED******REMOVED***label: String?,
***REMOVED******REMOVED***groupIdentifier: String?,
***REMOVED******REMOVED***limitOne: Bool
***REMOVED***) -> CFDictionary {
***REMOVED******REMOVED***var parameters = [CFString : Any]()
***REMOVED******REMOVED***parameters[kSecClass] = kSecClassGenericPassword
***REMOVED******REMOVED***parameters[kSecReturnAttributes] = true
***REMOVED******REMOVED***parameters[kSecReturnData] = true
***REMOVED******REMOVED***parameters[kSecAttrSynchronizable] = kSecAttrSynchronizableAny
***REMOVED******REMOVED***if let identifier = identifier {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrAccount] = identifier
***REMOVED***
***REMOVED******REMOVED***if limitOne {
***REMOVED******REMOVED******REMOVED***parameters[kSecMatchLimit] = kSecMatchLimitOne
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***parameters[kSecMatchLimit] = kSecMatchLimitAll
***REMOVED***
***REMOVED******REMOVED***if let label = label {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrLabel] = label
***REMOVED***
***REMOVED******REMOVED***if let groupIdentifier = groupIdentifier {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrAccessGroup] = groupIdentifier
***REMOVED***
***REMOVED******REMOVED***parameters[kSecUseDataProtectionKeychain] = true
***REMOVED******REMOVED***return parameters as CFDictionary
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Retrieves a generic password item from the keychain with a given identifier.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - identifier: The identifier of the item to retrieve.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
***REMOVED******REMOVED***/   search will not be limited to a particular group.
***REMOVED******REMOVED***/ - Returns: The found item or `nil` if an item with the specified identifier could
***REMOVED******REMOVED***/ not be found.
***REMOVED***func item(
***REMOVED******REMOVED***withIdentifier identifier: String,
***REMOVED******REMOVED***inGroup groupIdentifier: String? = nil
***REMOVED***) throws -> KeychainItem? {
***REMOVED******REMOVED***let parameters = Self.makeGetItemsParameters(
***REMOVED******REMOVED******REMOVED***identifier: identifier,
***REMOVED******REMOVED******REMOVED***label: nil,
***REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier,
***REMOVED******REMOVED******REMOVED***limitOne: true
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var result: CFTypeRef? = nil
***REMOVED******REMOVED***let status = SecItemCopyMatching(parameters, &result)
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case errSecSuccess:
***REMOVED******REMOVED******REMOVED***return KeychainItem(attributes: (result as! [CFString: Any]))
***REMOVED******REMOVED***case errSecItemNotFound:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***throw KeychainError(status: status)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Retrieves all generic password items in the keychain with a specific label.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The label of the items to be retrieved. Or `nil` if all
***REMOVED******REMOVED***/   generic password items should be retrieved.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
***REMOVED******REMOVED***/   search will not be limited to a particular group.
***REMOVED******REMOVED***/ - Returns: The found items.
***REMOVED***func items(
***REMOVED******REMOVED***labeled label: String? = nil,
***REMOVED******REMOVED***inGroup groupIdentifier: String? = nil
***REMOVED***) throws -> [KeychainItem] {
***REMOVED******REMOVED***let parameters = Self.makeGetItemsParameters(
***REMOVED******REMOVED******REMOVED***identifier: nil,
***REMOVED******REMOVED******REMOVED***label: label,
***REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier,
***REMOVED******REMOVED******REMOVED***limitOne: false
***REMOVED******REMOVED***)
***REMOVED******REMOVED***var result: CFTypeRef? = nil
***REMOVED******REMOVED***let status = SecItemCopyMatching(parameters, &result)
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case errSecSuccess:
***REMOVED******REMOVED******REMOVED***return (result as! [[CFString: Any]])
***REMOVED******REMOVED******REMOVED******REMOVED***.map(KeychainItem.init(attributes:))
***REMOVED******REMOVED***case errSecItemNotFound:
***REMOVED******REMOVED******REMOVED***return []
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***throw KeychainError(status: status)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ All generic password items in the keychain.
***REMOVED***var items: [KeychainItem] {
***REMOVED******REMOVED***get throws { try items() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Make the parameters for a remove item keychain operation.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - identifier: The identifier of the item to remove.
***REMOVED******REMOVED***/   - label: A label for the item.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group of the item to remove.
***REMOVED***static func makeRemoveItemParameters(
***REMOVED******REMOVED***identifier: String?,
***REMOVED******REMOVED***label: String?,
***REMOVED******REMOVED***groupIdentifier: String?
***REMOVED***) -> CFDictionary {
***REMOVED******REMOVED***var parameters = [CFString : Any]()
***REMOVED******REMOVED***if let identifier = identifier {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrAccount] = identifier
***REMOVED***
***REMOVED******REMOVED***parameters[kSecClass] = kSecClassGenericPassword
***REMOVED******REMOVED***if let label = label {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrLabel] = label
***REMOVED***
***REMOVED******REMOVED***if let groupIdentifier = groupIdentifier {
***REMOVED******REMOVED******REMOVED***parameters[kSecAttrAccessGroup] = groupIdentifier
***REMOVED***
***REMOVED******REMOVED***parameters[kSecAttrSynchronizable] = kSecAttrSynchronizableAny
***REMOVED******REMOVED***parameters[kSecUseDataProtectionKeychain] = true
***REMOVED******REMOVED***return parameters as CFDictionary
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes a generic password item with a given identifier from the keychain.
***REMOVED******REMOVED***/ - Parameters
***REMOVED******REMOVED***/   - identifier: The unique identifier that the item is stored under.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group of the item to remove.
***REMOVED***func removeItem(
***REMOVED******REMOVED***withIdentifier identifier: String,
***REMOVED******REMOVED***inGroup groupIdentifier: String? = nil
***REMOVED***) throws {
***REMOVED******REMOVED***let parameters = Self.makeRemoveItemParameters(
***REMOVED******REMOVED******REMOVED***identifier: identifier,
***REMOVED******REMOVED******REMOVED***label: nil,
***REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let status = SecItemDelete(parameters)
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case errSecSuccess, errSecItemNotFound:
***REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***throw KeychainError(status: status)!
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Removes a specified item from the keychain.
***REMOVED******REMOVED***/ - Parameter item: The item to be removed.
***REMOVED***func remove(item: KeychainItem) throws {
***REMOVED******REMOVED***return try removeItem(withIdentifier: item.identifier, inGroup: item.groupIdentifier)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Remove all generic password items with a specific label from the keychain.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - label: The label of the items to be removed, or `nil` if all
***REMOVED******REMOVED***/   items should be removed.
***REMOVED******REMOVED***/   - groupIdentifier: The identifier of the group of the item to remove.
***REMOVED***func removeItems(
***REMOVED******REMOVED***labeled label: String? = nil,
***REMOVED******REMOVED***inGroup groupIdentifier: String? = nil
***REMOVED***) throws {
***REMOVED******REMOVED***let parameters = Self.makeRemoveItemParameters(
***REMOVED******REMOVED******REMOVED***identifier: nil,
***REMOVED******REMOVED******REMOVED***label: label,
***REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let status = SecItemDelete(parameters)
***REMOVED******REMOVED***switch status {
***REMOVED******REMOVED***case errSecSuccess, errSecItemNotFound:
***REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***throw KeychainError(status: status)!
***REMOVED***
***REMOVED***
***REMOVED***

private extension KeychainAccess {
***REMOVED******REMOVED***/ The `CFString` value of the `Access`.
***REMOVED***var value: CFString {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .afterFirstUnlock:
***REMOVED******REMOVED******REMOVED***return kSecAttrAccessibleAfterFirstUnlock
***REMOVED******REMOVED***case .afterFirstUnlockThisDeviceOnly:
***REMOVED******REMOVED******REMOVED***return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
***REMOVED******REMOVED***case .whenUnlocked:
***REMOVED******REMOVED******REMOVED***return kSecAttrAccessibleWhenUnlocked
***REMOVED******REMOVED***case .whenUnlockedThisDeviceOnly:
***REMOVED******REMOVED******REMOVED***return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
***REMOVED******REMOVED***case .whenPasscodeSetThisDeviceOnly:
***REMOVED******REMOVED******REMOVED***return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
***REMOVED***
***REMOVED***
***REMOVED***

private extension KeychainItem {
***REMOVED******REMOVED***/ Initializes a keychain item with an attribute dictionary.
***REMOVED******REMOVED***/ - Parameter attributes: The attributes returned from a keychain query by which an item
***REMOVED******REMOVED***/ should be initialized with.
***REMOVED***init(attributes: [CFString: Any]) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***identifier: attributes[kSecAttrAccount]! as! String,
***REMOVED******REMOVED******REMOVED***service: (attributes[kSecAttrService] as? String).flatMap({ URL(string:$0) ***REMOVED***),
***REMOVED******REMOVED******REMOVED***created: attributes[kSecAttrCreationDate] as? Date,
***REMOVED******REMOVED******REMOVED***modified: attributes[kSecAttrModificationDate] as? Date,
***REMOVED******REMOVED******REMOVED***label: attributes[kSecAttrLabel] as? String,
***REMOVED******REMOVED******REMOVED***groupIdentifier: attributes[kSecAttrAccessGroup] as? String,
***REMOVED******REMOVED******REMOVED***isSynchronizable: attributes[kSecAttrSynchronizable] as? Bool ?? false,
***REMOVED******REMOVED******REMOVED***value: attributes["v_Data" as CFString] as? Data ?? Data()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ An enum that describes when an item in the keychain is accessible.
public enum KeychainAccess {
***REMOVED***case afterFirstUnlock
***REMOVED***case afterFirstUnlockThisDeviceOnly
***REMOVED***case whenUnlocked
***REMOVED***case whenUnlockedThisDeviceOnly
***REMOVED***case whenPasscodeSetThisDeviceOnly
***REMOVED***

***REMOVED***/ A value representing a generic password item in the keychain.
struct KeychainItem {
***REMOVED******REMOVED***/ The unique identifier of the item.
***REMOVED***var identifier: String
***REMOVED******REMOVED***/ The service this item is associated with.
***REMOVED***var service: URL?
***REMOVED******REMOVED***/ The date this item was created.
***REMOVED***var created: Date?
***REMOVED******REMOVED***/ The date this item was last modified.
***REMOVED***var modified: Date?
***REMOVED******REMOVED***/ A label for this item.
***REMOVED***var label: String?
***REMOVED******REMOVED***/ The identifier of the group that the item is stored in.
***REMOVED***var groupIdentifier: String?
***REMOVED******REMOVED***/ A value indicating whether the item is synchronized with iCloud.
***REMOVED***var isSynchronizable: Bool
***REMOVED******REMOVED***/ The data value of this item.
***REMOVED***var value: Data
***REMOVED***

***REMOVED***/ An error that can occur in a keychain operation.
struct KeychainError: Error, Hashable {
***REMOVED******REMOVED***/ The backing status code for this error.
***REMOVED******REMOVED***/ - Note: Status code numeric values can be found here:
***REMOVED******REMOVED***/ https:***REMOVED***opensource.apple.com/source/Security/Security-55471/libsecurity_keychain/lib/SecBase.h.auto.html
***REMOVED***let status: OSStatus
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Initializes a keychain error. This init will fail if the specified status is a success
***REMOVED******REMOVED***/ status value.
***REMOVED******REMOVED***/ - Parameter status: An `OSStatus`, usually the return value of a keychain operation.
***REMOVED***init?(status: OSStatus) {
***REMOVED******REMOVED***guard status != errSecSuccess else { return nil ***REMOVED***
***REMOVED******REMOVED***self.status = status
***REMOVED***
***REMOVED***

extension KeychainError {
***REMOVED******REMOVED*** The message for this error.
***REMOVED***var message: String {
***REMOVED******REMOVED***(SecCopyErrorMessageString(status, nil) as String?) ?? ""
***REMOVED***
***REMOVED***

extension KeychainError {
***REMOVED******REMOVED***/ The item was not found in the keychain.
***REMOVED***static let itemNotFound = Self(status: errSecItemNotFound)!
***REMOVED******REMOVED***/ One or more arguments specified were invalid.
***REMOVED***static let invalidArgument = Self(status: errSecParam)!
***REMOVED******REMOVED***/ An entitlement is missing.
***REMOVED***static let missingEntitlement = Self(status: errSecMissingEntitlement)!
***REMOVED***
