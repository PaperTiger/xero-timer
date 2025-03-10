import Foundation
import SwiftUI

@MainActor
class XeroDataManager: ObservableObject {
    @Published var projects: [Project] = []
    @Published var tasks: [XeroTask] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let persistenceManager = PersistenceManager.shared
    private let errorReporter = AppErrorReporter.shared
    
    func loadProjects() async throws {
        isLoading = true
        error = nil
        
        do {
            // Simulated network delay
            try await Task.sleep(for: .seconds(1))
            
            // Mock data for now
            projects = [
                Project(id: "1", name: "Project 1", client: "Client A", status: "Active"),
                Project(id: "2", name: "Project 2", client: "Client B", status: "Active"),
                Project(id: "3", name: "Project 3", client: "Client C", status: "Completed")
            ]
            
            tasks = [
                XeroTask(id: "1", projectID: "1", name: "Task 1"),
                XeroTask(id: "2", projectID: "1", name: "Task 2"),
                XeroTask(id: "3", projectID: "2", name: "Task 3")
            ]
        } catch {
            self.error = error
            errorReporter.reportError(error, severity: AppErrorSeverity.medium)
            throw error
        }
        
        isLoading = false
    }
    
    func syncTimeEntry(_ entry: XeroTimeEntry) async {
        do {
            // Mock sync for now
            try await Task.sleep(for: .seconds(1))
            print("Syncing time entry: \(entry.id)")
        } catch {
            errorReporter.reportError(error, severity: AppErrorSeverity.medium)
        }
    }
} 