import Foundation

struct ModelDescriptor: Identifiable, Hashable, Codable {
    var id: String                // provider-specific slug, e.g. "meta-llama/llama-3-70b-instruct"
    var displayName: String
    var provider: ProviderKind
    var contextTokens: Int?
    var supportsJSON: Bool
}
