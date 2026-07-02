import AppKit
import SwiftUI

@main
struct NetworkMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = NetworkStatusViewModel()

    var body: some Scene {
        MenuBarExtra(viewModel.menuBarTitle) {
            MenuBarView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dockに表示しないメニューバー常駐アプリとして起動する。
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}
