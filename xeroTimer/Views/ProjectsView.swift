import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    
    var body: some View {
        Group {
            if dataManager.isLoading {
                ProgressView()
            } else {
                projectsList
            }
        }
        .navigationTitle("Projects")
    }
    
    private var projectsList: some View {
        List {
            ForEach(dataManager.projects) { project in
                ProjectRow(project: project)
            }
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Name", value: project.name)
                LabeledContent("Client", value: project.client)
                LabeledContent("Status", value: project.status)
            }
            
            Section("Actions") {
                Button("Start Timer") {
                    // TODO: Implement start timer action
                }
            }
        }
        .navigationTitle(project.name)
    }
}

#Preview {
    ProjectsView()
        .environmentObject(XeroDataManager())
} 