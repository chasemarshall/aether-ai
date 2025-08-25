import Foundation

enum LLMError: Error, LocalizedError {
    case notConfigured
    case http(Int, String?)
    case streamParse
    case notImplemented
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API key not configured"
        case .http(let status, let message):
            return "HTTP \(status): \(message ?? "Unknown error")"
        case .streamParse:
            return "Failed to parse stream response"
        case .notImplemented:
            return "Provider not implemented"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
