import Foundation

public struct XeroTask: Identifiable, Codable, Hashable {
    public let id: String
    public let projectID: String
    public let name: String
    public let rate: Double?
    public let estimatedMinutes: Int?
    
    public init(id: String, projectID: String, name: String, rate: Double? = nil, estimatedMinutes: Int? = nil) {
        self.id = id
        self.projectID = projectID
        self.name = name
        self.rate = rate
        self.estimatedMinutes = estimatedMinutes
    }
}