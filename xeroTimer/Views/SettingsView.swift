import SwiftUI

struct SettingsView: View {
    @AppStorage("syncInterval") private var syncInterval = 5
    @AppStorage("autoStart") private var autoStart = true
    
    var body: some View {
        Form {
            Section("Sync Settings") {
                Stepper("Sync every \(syncInterval) minutes", value: $syncInterval, in: 1...60)
            }
            
            Section("Timer Settings") {
                Toggle("Auto-start timer when task selected", isOn: $autoStart)
            }
        }
        .padding()
    }
} 