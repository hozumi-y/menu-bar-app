import Foundation

enum NetworkConnectionType: String, Equatable {
    case wifi = "Wi-Fi"
    case ethernet = "Ethernet"
    case cellular = "Cellular"
    case other = "Other"
    case unknown = "Unknown"
}

struct NetworkInfo: Equatable {
    var isOnline: Bool
    var connectionType: NetworkConnectionType
    var globalIPAddress: String
    var localIPAddress: String
    var proxy: String
    var vpn: String
    var dns: String
    var lastUpdated: Date?

    var connectionStatusText: String {
        isOnline ? "オンライン" : "オフライン"
    }

    var connectionTypeText: String {
        connectionType.rawValue
    }

    var menuBarTitle: String {
        guard isOnline else { return "⚠️ Offline" }

        switch connectionType {
        case .wifi:
            return "🌐 Wi-Fi"
        case .ethernet:
            return "🌐 Ethernet"
        case .cellular, .other, .unknown:
            return "🌐 Network"
        }
    }

    static let placeholder = NetworkInfo(
        isOnline: false,
        connectionType: .unknown,
        globalIPAddress: "未取得",
        localIPAddress: "未取得",
        proxy: "未取得",
        vpn: "未取得",
        dns: "未取得",
        lastUpdated: nil
    )
}
