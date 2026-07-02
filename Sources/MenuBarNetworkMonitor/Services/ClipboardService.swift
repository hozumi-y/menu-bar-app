import AppKit

protocol ClipboardServicing {
    func copy(_ text: String)
}

final class ClipboardService: ClipboardServicing {
    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
