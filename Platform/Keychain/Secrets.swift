import Foundation
import Security

struct Secrets {
    private static let service = "com.byokapp.secrets"
    
    static func save(key: String, value: String) -> Bool {
        let data = Data(value.utf8)
        
        // Delete any existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// Convenience methods for specific keys
extension Secrets {
    static var openRouterAPIKey: String? {
        get { load(key: "openrouter_api_key") }
        set { 
            if let value = newValue {
                _ = save(key: "openrouter_api_key", value: value)
            } else {
                _ = delete(key: "openrouter_api_key")
            }
        }
    }
    
    static var anthropicAPIKey: String? {
        get { load(key: "anthropic_api_key") }
        set { 
            if let value = newValue {
                _ = save(key: "anthropic_api_key", value: value)
            } else {
                _ = delete(key: "anthropic_api_key")
            }
        }
    }
    
    static var openAIAPIKey: String? {
        get { load(key: "openai_api_key") }
        set { 
            if let value = newValue {
                _ = save(key: "openai_api_key", value: value)
            } else {
                _ = delete(key: "openai_api_key")
            }
        }
    }
}
