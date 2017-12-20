/*
 * Copyright (c) 2017, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Foundation

public class OktaKeychain: NSObject {

    static var backgroundAccess = false

    internal class func setBackgroundAccess(access:Bool) {
        self.backgroundAccess = access
    }

    internal class func set(key: String, object: String, access: Bool) {
        guard let data = object.data(using: .utf8) else {
            print("Error storing to Keychain.")
            return
        }

        set(key: key, objectData: data, access: access)
    }

    internal class func set(key: String, objectData: Data, access: Bool) {
        let q = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecValueData as String: objectData,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: getAccessibility()
        ] as CFDictionary

        // Delete existing (if applicable)
        SecItemDelete(q)

        // Store to keychain
        let sanityCheck = SecItemAdd(q, nil)
        if sanityCheck != noErr {
            print("Error Storing to Keychain: \(sanityCheck.description)")
        }
    }

    internal class func get(key: String) -> String? {
        if let parsedData = self.getData(key: key) {
            return String(data: parsedData, encoding: .utf8)
        } else {
            print("Could not parse data as String")
        }
        return nil
    }

    internal class func getData(key: String) -> Data? {
        let q = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: getAccessibility()
        ] as CFDictionary

        var ref: AnyObject? = nil

        let sanityCheck = SecItemCopyMatching(q, &ref)

        if sanityCheck != noErr { return nil }
        if let parsedData = ref as? Data {
            return parsedData
        }
        return nil
    }

    internal class func removeAll() {
        let secItemClasses = [ kSecClassGenericPassword ]

        for secItemClass in secItemClasses {
            let dictionary = [ kSecClass as String:secItemClass ] as CFDictionary
            SecItemDelete(dictionary)
        }
    }

    internal class func getAccessibility() -> CFString {
        if self.backgroundAccess {
            // If the device needs background keychain access, grant permission
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        } else {
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        }
    }
}
