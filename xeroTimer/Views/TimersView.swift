import SwiftUI

struct TimersView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    @State private var timers: [XeroTimeEntry] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if timers.isEmpty {
                Text("No active timers")
                    .foregroundColor(.secondary)
            } else {
                ForEach(timers) { timer in
                    TimerRow(timer: timer)
                }
            }
        }
        .navigationTitle("Timers")
        .onAppear {
            loadTimers()
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") {
                error = nil
            }
        } message: {
            Text(error?.localizedDescription ?? "Unknown error")
        }
    }
    
    private func loadTimers() {
        timers = PersistenceManager.shared.loadTimers()
    }
}

#Preview {
    TimersView()
        .environmentObject(XeroDataManager())
} 