import SwiftUI

struct ProjectRow: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .font(.headline)
            Text(project.client)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProjectRow(project: Project(id: "1", name: "Test Project", client: "Test Client", status: "Active"))
} 