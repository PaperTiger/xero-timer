import Foundation

// MARK: - Error Types and Protocols
public enum AppErrorSeverity: String, Codable {
    case low
    case medium
    case high
    case critical
}

public enum AppError: LocalizedError {
    case networkError(Error)
    case validationError(String)
    case persistenceError(String)
    case syncError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .persistenceError(let message):
            return "Storage error: \(message)"
        case .syncError(let message):
            return "Sync error: \(message)"
        }
    }
}

public protocol AppErrorReporting {
    func reportError(_ error: Error, severity: AppErrorSeverity)
}

// MARK: - Error Reporting Service
public final class AppErrorReporter {
    public static let shared = AppErrorReporter()
    
    private var errorQueue: [(Error, AppErrorSeverity, Date)] = []
    private let maxStoredErrors = 100
    
    private init() {}
}

// MARK: - Protocol Implementation
extension AppErrorReporter: AppErrorReporting {
    public func reportError(_ error: Error, severity: AppErrorSeverity) {
        // Simplified implementation for now
        print("Error reported: \(error.localizedDescription) with severity: \(severity.rawValue)")
        
        errorQueue.append((error, severity, Date()))
        if errorQueue.count > maxStoredErrors {
            errorQueue.removeFirst()
        }
    }
}