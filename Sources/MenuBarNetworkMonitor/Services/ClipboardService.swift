import AppKit

protocol ClipboardServicing {
    func copy(_ text: String)
}

final class ClipboardService: ClipboardServicing {
    func copy(_ text: String) {
        // 今後のコピー機能追加に備えた仮実装。
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
