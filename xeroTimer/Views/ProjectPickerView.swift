import SwiftUI

struct ProjectPickerView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    @Binding var selectedProject: Project?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Project")
                .font(.headline)
            
            Picker("Select a project", selection: $selectedProject) {
                Text("Select a project")
                    .tag(Optional<Project>.none)
                
                ForEach(dataManager.projects) { project in
                    Text("\(project.name) (\(project.client))")
                        .tag(Optional(project))
                }
            }
            .labelsHidden()
        }
        .onAppear {
            if dataManager.projects.isEmpty {
                let _ = SwiftUI.Task {
                    try? await dataManager.loadProjects()
                }
            }
        }
    }
}

struct ProjectPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectPickerView(selectedProject: .constant(nil))
            .environmentObject(XeroDataManager())
    }
} 