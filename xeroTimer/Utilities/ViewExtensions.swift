import SwiftUI

extension View {
    func openInWindow(title: String, sender: Any?) {
        let controller = NSHostingController(rootView: self)
        let window = NSWindow(contentViewController: controller)
        window.title = title
        window.makeKeyAndOrderFront(sender)
    }
} 