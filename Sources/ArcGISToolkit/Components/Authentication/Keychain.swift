//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import Foundation

/// An actor that provides access to the device keychain.
actor Keychain {
    /// The shared instance.
    static let shared = Keychain()
    
    private init() {}
    
    /// Creates parameters for storing a generic password item in the keychain.
    /// - Parameters:
    ///   - identifier: The unique identifier for the item.
    ///   - value: The data value of the item.
    ///   - access: When the item can be accessed.
    ///   - service: The associated service of the item.
    ///   - label: A label for the item.
    ///   - groupIdentifier: The identifier of the group that the item should be stored in.
    ///   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
    static func makeStoreItemParameters(
        identifier: String,
        value: Data,
        access: KeychainAccess,
        service: String?,
        label: String?,
        groupIdentifier: String?,
        isSynchronizable: Bool
    ) -> CFDictionary {
        var parameters = [CFString : Any]()
        parameters[kSecClass] = kSecClassGenericPassword
        parameters[kSecAttrAccount] = identifier
        if let service = service {
            parameters[kSecAttrService] = service
        }
        if let label = label {
            parameters[kSecAttrLabel] = label
        }
        parameters[kSecValueData] = value
        parameters[kSecAttrAccessible] = access.value
        parameters[kSecAttrAccessGroup] = groupIdentifier
        parameters[kSecAttrSynchronizable] = isSynchronizable
        // This is highly recommended to be set to true for all keychain operations.
        // This key helps to improve the portability of your code across platforms.
        // More information here: https://developer.apple.com/documentation/security/ksecusedataprotectionkeychain
        parameters[kSecUseDataProtectionKeychain] = true
        return parameters as CFDictionary
    }
    
    /// Stores a generic password item in the keychain.
    /// - Remark: If no group is specified then the item will be stored in the default group.
    /// To know more about what the default group would be you can find information about that here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
    /// - Parameters:
    ///   - identifier: The unique identifier for the item to be stored under.
    ///   - value: The data value of the item.
    ///   - access: When the item can be accessed.
    ///   - service: The service that the item is associated with.
    ///   - label: A label for the item.
    ///   - groupIdentifier: The identifier of the group that the item should be stored in.
    ///   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
    func storeItem(
        identifier: String,
        value: Data,
        access: KeychainAccess,
        service: URL? = nil,
        label: String? = nil,
        groupIdentifier: String? = nil,
        isSynchronizable: Bool = false
    ) throws {
        try removeItem(withIdentifier: identifier)
        let parameters = Self.makeStoreItemParameters(
            identifier: identifier,
            value: value,
            access: access,
            service: service?.absoluteString,
            label: label,
            groupIdentifier: groupIdentifier,
            isSynchronizable: isSynchronizable
        )
        let status = SecItemAdd(parameters, nil)
        guard status == errSecSuccess else {
            throw KeychainError(status: status)!
        }
    }
    
    /// Creates parameters for retrieving items from the keychain.
    /// - Parameters:
    ///   - identifier: The identifier of the item to retrieve.
    ///   - label: The label of the item to retrieve.
    ///   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
    ///   search will not be limited to a particular group.
    ///   - limitOne: A value indicating if only a single result should be returned.
    static func makeGetItemsParameters(
        identifier: String?,
        label: String?,
        groupIdentifier: String?,
        limitOne: Bool
    ) -> CFDictionary {
        var parameters = [CFString : Any]()
        parameters[kSecClass] = kSecClassGenericPassword
        parameters[kSecReturnAttributes] = true
        parameters[kSecReturnData] = true
        parameters[kSecAttrSynchronizable] = kSecAttrSynchronizableAny
        if let identifier = identifier {
            parameters[kSecAttrAccount] = identifier
        }
        if limitOne {
            parameters[kSecMatchLimit] = kSecMatchLimitOne
        } else {
            parameters[kSecMatchLimit] = kSecMatchLimitAll
        }
        if let label = label {
            parameters[kSecAttrLabel] = label
        }
        if let groupIdentifier = groupIdentifier {
            parameters[kSecAttrAccessGroup] = groupIdentifier
        }
        parameters[kSecUseDataProtectionKeychain] = true
        return parameters as CFDictionary
    }
    
    /// Retrieves a generic password item from the keychain with a given identifier.
    /// - Parameters:
    ///   - identifier: The identifier of the item to retrieve.
    ///   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
    ///   search will not be limited to a particular group.
    /// - Returns: The found item or `nil` if an item with the specified identifier could
    /// not be found.
    func item(
        withIdentifier identifier: String,
        inGroup groupIdentifier: String? = nil
    ) throws -> KeychainItem? {
        let parameters = Self.makeGetItemsParameters(
            identifier: identifier,
            label: nil,
            groupIdentifier: groupIdentifier,
            limitOne: true
        )
        var result: CFTypeRef? = nil
        let status = SecItemCopyMatching(parameters, &result)
        switch status {
        case errSecSuccess:
            return KeychainItem(attributes: (result as! [CFString: Any]))
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(status: status)!
        }
    }
    
    /// Retrieves all generic password items in the keychain with a specific label.
    /// - Parameters:
    ///   - label: The label of the items to be retrieved. Or `nil` if all
    ///   generic password items should be retrieved.
    ///   - groupIdentifier: The identifier of the group to limit the search to. If `nil` then the
    ///   search will not be limited to a particular group.
    /// - Returns: The found items.
    func items(
        labeled label: String? = nil,
        inGroup groupIdentifier: String? = nil
    ) throws -> [KeychainItem] {
        let parameters = Self.makeGetItemsParameters(
            identifier: nil,
            label: label,
            groupIdentifier: groupIdentifier,
            limitOne: false
        )
        var result: CFTypeRef? = nil
        let status = SecItemCopyMatching(parameters, &result)
        switch status {
        case errSecSuccess:
            return (result as! [[CFString: Any]])
                .map(KeychainItem.init(attributes:))
        case errSecItemNotFound:
            return []
        default:
            throw KeychainError(status: status)!
        }
    }
    
    /// All generic password items in the keychain.
    var items: [KeychainItem] {
        get throws { try items() }
    }
    
    /// Make the parameters for a remove item keychain operation.
    /// - Parameters:
    ///   - identifier: The identifier of the item to remove.
    ///   - label: A label for the item.
    ///   - groupIdentifier: The identifier of the group of the item to remove.
    static func makeRemoveItemParameters(
        identifier: String?,
        label: String?,
        groupIdentifier: String?
    ) -> CFDictionary {
        var parameters = [CFString : Any]()
        if let identifier = identifier {
            parameters[kSecAttrAccount] = identifier
        }
        parameters[kSecClass] = kSecClassGenericPassword
        if let label = label {
            parameters[kSecAttrLabel] = label
        }
        if let groupIdentifier = groupIdentifier {
            parameters[kSecAttrAccessGroup] = groupIdentifier
        }
        parameters[kSecAttrSynchronizable] = kSecAttrSynchronizableAny
        parameters[kSecUseDataProtectionKeychain] = true
        return parameters as CFDictionary
    }
    
    /// Removes a generic password item with a given identifier from the keychain.
    /// - Parameters
    ///   - identifier: The unique identifier that the item is stored under.
    ///   - groupIdentifier: The identifier of the group of the item to remove.
    func removeItem(
        withIdentifier identifier: String,
        inGroup groupIdentifier: String? = nil
    ) throws {
        let parameters = Self.makeRemoveItemParameters(
            identifier: identifier,
            label: nil,
            groupIdentifier: groupIdentifier
        )
        let status = SecItemDelete(parameters)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError(status: status)!
        }
    }
    
    /// Removes a specified item from the keychain.
    /// - Parameter item: The item to be removed.
    func remove(item: KeychainItem) throws {
        return try removeItem(withIdentifier: item.identifier, inGroup: item.groupIdentifier)
    }
    
    /// Remove all generic password items with a specific label from the keychain.
    /// - Parameters:
    ///   - label: The label of the items to be removed, or `nil` if all
    ///   items should be removed.
    ///   - groupIdentifier: The identifier of the group of the item to remove.
    func removeItems(
        labeled label: String? = nil,
        inGroup groupIdentifier: String? = nil
    ) throws {
        let parameters = Self.makeRemoveItemParameters(
            identifier: nil,
            label: label,
            groupIdentifier: groupIdentifier
        )
        let status = SecItemDelete(parameters)
        switch status {
        case errSecSuccess, errSecItemNotFound:
            return
        default:
            throw KeychainError(status: status)!
        }
    }
}

private extension KeychainAccess {
    /// The `CFString` value of the `Access`.
    var value: CFString {
        switch self {
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}

private extension KeychainItem {
    /// Initializes a keychain item with an attribute dictionary.
    /// - Parameter attributes: The attributes returned from a keychain query by which an item
    /// should be initialized with.
    init(attributes: [CFString: Any]) {
        self.init(
            identifier: attributes[kSecAttrAccount]! as! String,
            service: (attributes[kSecAttrService] as? String).flatMap({ URL(string:$0) }),
            created: attributes[kSecAttrCreationDate] as? Date,
            modified: attributes[kSecAttrModificationDate] as? Date,
            label: attributes[kSecAttrLabel] as? String,
            groupIdentifier: attributes[kSecAttrAccessGroup] as? String,
            isSynchronizable: attributes[kSecAttrSynchronizable] as? Bool ?? false,
            value: attributes["v_Data" as CFString] as? Data ?? Data()
        )
    }
}

/// An enum that describes when an item in the keychain is accessible.
public enum KeychainAccess {
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly
    case whenUnlocked
    case whenUnlockedThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly
}

/// A value representing a generic password item in the keychain.
struct KeychainItem {
    /// The unique identifier of the item.
    var identifier: String
    /// The service this item is associated with.
    var service: URL?
    /// The date this item was created.
    var created: Date?
    /// The date this item was last modified.
    var modified: Date?
    /// A label for this item.
    var label: String?
    /// The identifier of the group that the item is stored in.
    var groupIdentifier: String?
    /// A value indicating whether the item is synchronized with iCloud.
    var isSynchronizable: Bool
    /// The data value of this item.
    var value: Data
}

/// An error that can occur in a keychain operation.
struct KeychainError: Error, Hashable {
    /// The backing status code for this error.
    /// - Note: Status code numeric values can be found here:
    /// https://opensource.apple.com/source/Security/Security-55471/libsecurity_keychain/lib/SecBase.h.auto.html
    let status: OSStatus
    
    
    /// Initializes a keychain error. This init will fail if the specified status is a success
    /// status value.
    /// - Parameter status: An `OSStatus`, usually the return value of a keychain operation.
    init?(status: OSStatus) {
        guard status != errSecSuccess else { return nil }
        self.status = status
    }
}

extension KeychainError {
    // The message for this error.
    var message: String {
        (SecCopyErrorMessageString(status, nil) as String?) ?? ""
    }
}

extension KeychainError {
    /// The item was not found in the keychain.
    static let itemNotFound = Self(status: errSecItemNotFound)!
    /// One or more arguments specified were invalid.
    static let invalidArgument = Self(status: errSecParam)!
    /// An entitlement is missing.
    static let missingEntitlement = Self(status: errSecMissingEntitlement)!
}
