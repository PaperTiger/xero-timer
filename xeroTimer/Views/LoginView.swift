import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: XeroAuthManager
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Xero Timer")
                .font(.title)
            
            if isLoading {
                ProgressView()
            } else {
                Button(action: signIn) {
                    Text("Sign in with Xero")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.localizedDescription ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK")) {
                    error = nil
                }
            )
        }
    }
    
    private func signIn() {
        Task { @MainActor in
            isLoading = true
            do {
                try await authManager.authenticate()
            } catch {
                self.error = error
                self.showError = true
            }
            isLoading = false
        }
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(XeroAuthManager.shared)
    }
} 