import Foundation
import SwiftUI

enum ValidationError: LocalizedError {
    case emptyProjectID
    case emptyTaskID
    case invalidDuration
    
    var errorDescription: String? {
        switch self {
        case .emptyProjectID:
            return "Project ID cannot be empty"
        case .emptyTaskID:
            return "Task ID cannot be empty"
        case .invalidDuration:
            return "Duration must be greater than 0"
        }
    }
}

class ValidationService {
    static let shared = ValidationService()
    
    private init() {}
    
    func validateTimeEntry(_ entry: XeroTimeEntry) throws {
        if entry.projectID.isEmpty {
            throw ValidationError.emptyProjectID
        }
        
        if entry.taskID.isEmpty {
            throw ValidationError.emptyTaskID
        }
        
        if entry.duration <= 0 {
            throw ValidationError.invalidDuration
        }
    }
}

#if DEBUG
// Preview helper
extension ValidationService {
    static func validateTimeEntryForPreview(_ entry: XeroTimeEntry) -> Bool {
        do {
            try shared.validateTimeEntry(entry)
            return true
        } catch {
            return false
        }
    }
}
#endif 