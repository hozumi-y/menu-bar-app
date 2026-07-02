import AppKit

protocol ClipboardServicing {
    @discardableResult
    func copy(_ text: String) -> Bool
}

final class ClipboardService: ClipboardServicing {
    @discardableResult
    func copy(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        return pasteboard.setString(text, forType: .string)
    }
}
