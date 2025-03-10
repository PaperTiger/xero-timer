import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    @EnvironmentObject var authManager: XeroAuthManager
    @State private var selectedProject: Project? = nil
    @State private var showingProjectPicker = false
    
    var body: some View {
        VStack {
            if authManager.isAuthenticated {
                if let project = selectedProject {
                    ProjectTimerView(project: project)
                } else {
                    Button("Select Project") {
                        showingProjectPicker = true
                    }
                }
            } else {
                Button("Sign In") {
                    let _ = SwiftUI.Task {
                        try? await authManager.authenticate()
                    }
                }
            }
            
            Divider()
            
            NavigationLink("Projects") {
                ProjectsView()
                    .frame(width: 400, height: 300)
            }
            
            NavigationLink("Settings") {
                SettingsView()
                    .frame(width: 300, height: 200)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 300)
        .sheet(isPresented: $showingProjectPicker) {
            ProjectPickerView(selectedProject: $selectedProject)
                .environmentObject(dataManager)
        }
    }
}

struct ProjectTimerView: View {
    let project: Project
    @State private var isRunning = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .font(.headline)
            Text(project.client)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(isRunning ? "Stop" : "Start") {
                isRunning.toggle()
            }
        }
    }
}

// MARK: - Custom Button Style
struct HoverButtonStyle: ButtonStyle {
    let role: ButtonRole?
    @Binding var isHovered: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor(configuration: configuration))
            .cornerRadius(6)
            .foregroundColor(foregroundColor(configuration: configuration))
    }
    
    private func backgroundColor(configuration: Configuration) -> Color {
        if configuration.isPressed {
            return role == .destructive ? .red.opacity(0.8) : .blue.opacity(0.8)
        } else if isHovered {
            return role == .destructive ? .red.opacity(0.6) : .blue.opacity(0.6)
        } else {
            return role == .destructive ? .red.opacity(0.4) : .blue.opacity(0.4)
        }
    }
    
    private func foregroundColor(configuration: Configuration) -> Color {
        return .white
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let title: String
    let systemImage: String
    let keyboardShortcut: String
    let id: String
    var role: ButtonRole? = nil
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title)
            }
        }
        .buttonStyle(HoverButtonStyle(role: role, isHovered: $isHovered))
        .onHover { hovering in
            isHovered = hovering
        }
        .keyboardShortcut(KeyEquivalent(Character(keyboardShortcut)))
    }
}

#Preview {
    MenuBarView()
        .environmentObject(XeroDataManager())
        .environmentObject(XeroAuthManager.shared)
} 