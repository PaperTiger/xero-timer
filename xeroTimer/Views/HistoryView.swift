import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    @State private var completedTimers: [XeroTimeEntry] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if completedTimers.isEmpty {
                Text("No completed timers")
                    .foregroundColor(.secondary)
            } else {
                ForEach(completedTimers) { timer in
                    TimerRow(timer: timer)
                }
            }
        }
        .navigationTitle("History")
        .onAppear {
            loadCompletedTimers()
        }
    }
    
    private func loadCompletedTimers() {
        completedTimers = PersistenceManager.shared.loadTimers().filter { $0.endDate != nil }
    }
}

#Preview {
    HistoryView()
        .environmentObject(XeroDataManager())
} 