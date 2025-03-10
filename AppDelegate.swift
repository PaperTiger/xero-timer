class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        XeroAuthManager.shared.handleCallback(url: url)
    }
} 