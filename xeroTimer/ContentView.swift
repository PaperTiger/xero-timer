//
//  ContentView.swift
//  xeroTimer
//
//  Created by Marc Debiak on 3/7/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var dataManager: XeroDataManager
    @EnvironmentObject var authManager: XeroAuthManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Active Timers", destination: TimersView())
                    NavigationLink("History", destination: HistoryView())
                }
                
                Section {
                    NavigationLink("Projects", destination: ProjectsView())
                    NavigationLink("Settings", destination: SettingsView())
                }
            }
            .navigationTitle("Xero Timer")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        authenticate()
                    } label: {
                        Image(systemName: authManager.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundColor(authManager.isAuthenticated ? .green : .red)
                    }
                }
            }
        }
    }
    
    private func authenticate() {
        Task { @MainActor in
            try? await authManager.authenticate()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(XeroDataManager())
            .environmentObject(XeroAuthManager.shared)
    }
}
