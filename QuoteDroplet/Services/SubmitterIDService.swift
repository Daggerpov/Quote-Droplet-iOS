//
//  SubmitterIDService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2026-11-02.
//

import Foundation
import Security

// Anonymous per-device ID sent with quote submissions, so the user can later see their own submissions.
// Stored in the Keychain so it survives app reinstalls.
enum SubmitterIDService {
    private static let service = "com.Daggerpov.Quote-Droplet.submitterID"
    private static let account = "submitterID"

    static func getOrCreate() -> String {
        if let existing = read() {
            return existing
        }
        let newID = UUID().uuidString
        save(newID)
        return newID
    }

    private static func read() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    private static func save(_ id: String) {
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(id.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess && status != errSecDuplicateItem {
            print("⚠️ SubmitterIDService: Failed to save submitter ID to Keychain (status \(status))")
        }
    }
}
