import Foundation

enum AsyncUtils {
    static func delay(seconds: Double) async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
                continuation.resume(returning: ())
            }
        }
    }
} 