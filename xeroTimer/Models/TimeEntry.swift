import Foundation
import SwiftUI

public final class XeroTimeEntry: Identifiable, ObservableObject, Codable {
    public let id: String
    public let projectID: String
    public let taskID: String
    @Published public var description: String
    @Published public var startDate: Date
    @Published public var endDate: Date?
    @Published public var duration: TimeInterval = 0
    @Published public var isActive: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var synced: Bool = false
    private var timer: Timer?
    private var pausedDuration: TimeInterval = 0
    
    enum CodingKeys: String, CodingKey {
        case id, projectID, taskID, description, startDate, endDate, duration, isActive, isPaused, synced
    }
    
    public init(projectID: String, taskID: String, description: String = "") {
        self.id = UUID().uuidString
        self.projectID = projectID
        self.taskID = taskID
        self.description = description
        self.startDate = Date()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        projectID = try container.decode(String.self, forKey: .projectID)
        taskID = try container.decode(String.self, forKey: .taskID)
        description = try container.decode(String.self, forKey: .description)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        isPaused = try container.decode(Bool.self, forKey: .isPaused)
        synced = try container.decode(Bool.self, forKey: .synced)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(projectID, forKey: .projectID)
        try container.encode(taskID, forKey: .taskID)
        try container.encode(description, forKey: .description)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(duration, forKey: .duration)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(isPaused, forKey: .isPaused)
        try container.encode(synced, forKey: .synced)
    }
    
    public func start() {
        if !isActive {
            isActive = true
            startDate = Date()
            startTimer()
        }
    }
    
    public func pause() {
        isPaused = true
        timer?.invalidate()
        timer = nil
        pausedDuration = duration
    }
    
    public func resume() {
        isPaused = false
        startTimer()
    }
    
    public func stop() {
        isActive = false
        isPaused = false
        endDate = Date()
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPaused {
                self.duration = Date().timeIntervalSince(self.startDate) + self.pausedDuration
            }
        }
    }
}

// Add this extension to help with type resolution
extension XeroTimeEntry {
    public static var namespace: XeroTimeEntry.Type {
        return XeroTimeEntry.self
    }
} 