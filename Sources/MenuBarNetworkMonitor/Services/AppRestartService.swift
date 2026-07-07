import AppKit
import Foundation

protocol AppRestartServicing {
    func restart()
}

final class AppRestartService: AppRestartServicing {
    private let bundle: Bundle
    private let workspace: NSWorkspace
    private let application: NSApplication

    init(
        bundle: Bundle = .main,
        workspace: NSWorkspace = .shared,
        application: NSApplication = .shared
    ) {
        self.bundle = bundle
        self.workspace = workspace
        self.application = application
    }

    func restart() {
        let applicationURL = bundle.bundleURL
        guard applicationURL.isFileURL else {
            NSLog("アプリの再起動に失敗しました: アプリURLを取得できませんでした。")
            return
        }

        guard applicationURL.pathExtension == "app" else {
            NSLog("アプリの再起動に失敗しました: bundleURLが.appを指していません: %@", applicationURL.absoluteString)
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true

        workspace.openApplication(at: applicationURL, configuration: configuration) { [weak self] _, error in
            if let error {
                NSLog("アプリの再起動に失敗しました: %@", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                self?.application.terminate(nil)
            }
        }
    }
}
