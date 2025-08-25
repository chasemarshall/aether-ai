import Foundation

struct ChatMessage: Identifiable, Codable, Hashable {
    enum Role: String, Codable {
        case system
        case user
        case assistant
        case tool
    }
    
    let id: UUID
    var role: Role
    var content: String
    var createdAt: Date
    
    init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}
