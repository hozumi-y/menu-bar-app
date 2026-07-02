import AppKit
import SwiftUI

@main
struct MenuBarNetworkMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = NetworkStatusViewModel()

    var body: some Scene {
        MenuBarExtra(viewModel.networkInfo.menuBarTitle) {
            MenuBarView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}
