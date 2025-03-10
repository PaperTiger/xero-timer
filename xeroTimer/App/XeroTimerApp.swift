import SwiftUI
import AppKit

// Add AppDelegate class
class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            print("Received URL: \(url)") // Debug print
            
            // Parse the URL components
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems else {
                print("Invalid URL structure")
                return
            }
            
            // Debug print the query items
            queryItems.forEach { item in
                print("Query item: \(item.name) = \(item.value ?? "nil")")
            }
            
            // Handle the callback
            XeroAuthManager.shared.handleCallback(url: url)
            
            // Bring app to front
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}

// Create a singleton observer class to handle notifications
class URLCallbackHandler {
    static let shared = URLCallbackHandler()
    
    init() {
        NotificationCenter.default.addObserver(
            forName: .handleXeroCallback,
            object: nil,
            queue: .main
        ) { notification in
            if let url = notification.object as? URL {
                XeroAuthManager.shared.handleCallback(url: url)
                
                // Bring app to front
                DispatchQueue.main.async {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}

@main
struct XeroTimerApp: App {
    @StateObject private var dataManager = XeroDataManager()
    @StateObject private var authManager = XeroAuthManager.shared
    
    // Add AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Initialize the URL handler
    private let urlHandler = URLCallbackHandler.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
        }
    }
}

// Add notification name extension
extension Notification.Name {
    static let handleXeroCallback = Notification.Name("handleXeroCallback")
}

class MenuBarManager {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    
    init(dataManager: XeroDataManager, authManager: XeroAuthManager) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up the menu bar icon
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Xero Timer")
            button.imagePosition = .imageLeft
        }
        
        // Set up the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
        )
        
        // Add click handler
        statusItem.button?.action = #selector(togglePopover(_:))
        statusItem.button?.target = self
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
} 