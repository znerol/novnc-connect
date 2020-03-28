import AppKit

class AppDelegate: NSObject {
    var statusBarItem: NSStatusItem?

    func statusMenuAttach(statusBar: NSStatusBar) -> NSStatusItem {
        let item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "N"

        let statusBarMenu = NSMenu(title: "NoVNC Connect")
        item.menu = statusBarMenu

        statusBarMenu.addItem(
            withTitle: "Connect",
            action: #selector(AppDelegate.statusMenuConnect),
            keyEquivalent: ""
        )

        statusBarMenu.addItem(.separator())

        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.statusMenuQuit),
            keyEquivalent: ""
        )

        return item
    }

    @objc
    func statusMenuConnect() {
        let alert = NSAlert()
        alert.messageText = "Connect to noVNC"
        alert.informativeText = "Paste a noVNC URL into the text field in order to start the Screen Sharing application"
        alert.addButton(withTitle: "Connect")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 96))
        if let value = NSPasteboard.general.string(forType: .string), let _ = URL(fromNoVNC: value) {
            input.stringValue = value
        } else {
            input.stringValue = ""
        }
        alert.accessoryView = input

        let app = NSApplication.shared
        app.activate(ignoringOtherApps: true)

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            if let url = URL(fromNoVNC: input.stringValue) {
                Tunnel(url: url).open(self)
            } else {
                urlMalformed()
            }
        default:
            break
        }

        app.deactivate()
    }

    @objc
    func statusMenuQuit() {
        NSApplication.shared.terminate(self)
    }

    func screenSharingStart(host: String, port: UInt16) {
        NSWorkspace.shared.open(URL(string: "vnc://\(host):\(port)")!)
    }

    func tunnelFailed(error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = "Connection failed"

        let app = NSApplication.shared
        app.activate(ignoringOtherApps: true)
        alert.runModal()
        app.deactivate()
    }

    func urlMalformed() {
        let alert = NSAlert()
        alert.messageText = "Malformed URL"

        let app = NSApplication.shared
        app.activate(ignoringOtherApps: true)
        alert.runModal()
        app.deactivate()
    }
}

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        statusBarItem = statusMenuAttach(statusBar: NSStatusBar.system)
    }
}

extension AppDelegate: TunnelDelegate {
    func tunnel(opened _: Tunnel, port: UInt16) {
        screenSharingStart(host: "[::1]", port: port)
    }

    func tunnel(failed _: Tunnel, error: Error) {
        tunnelFailed(error: error)
    }
}
