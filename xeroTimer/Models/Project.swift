import Foundation

public struct Project: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let client: String
    public let status: String
    
    public init(id: String, name: String, client: String, status: String) {
        self.id = id
        self.name = name
        self.client = client
        self.status = status
    }
    
    // Implement Hashable manually to ensure consistent hashing
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
} 