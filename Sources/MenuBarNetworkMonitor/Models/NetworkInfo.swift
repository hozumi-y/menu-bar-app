import Foundation

enum ConnectionType: String, Equatable {
    case wifi = "Wi-Fi"
    case ethernet = "Ethernet"
    case cellular = "Cellular"
    case other = "Other"
    case unknown = "Unknown"
}

struct NetworkInfo: Equatable {
    var isOnline: Bool
    var connectionType: ConnectionType
    var globalIPAddress: String
    var localIPAddress: String
    var proxyInfo: ProxyInfo
    var vpnInfo: VPNInfo
    var dns: String
    var isFetchingGlobalIP: Bool
    var lastUpdated: Date?

    var connectionStatusText: String {
        isOnline ? "オンライン" : "オフライン"
    }

    var connectionTypeText: String {
        connectionType.rawValue
    }

    var lastUpdatedText: String {
        guard let lastUpdated else { return "未取得" }
        return Self.lastUpdatedFormatter.string(from: lastUpdated)
    }

    var menuBarTitle: String {
        guard isOnline else { return "⚠️ Offline" }

        let ipAddressText = isFetchingGlobalIP ? "取得中" : globalIPAddress
        let displayIPAddress = globalIPAddress == "取得失敗" ? "IP取得失敗" : ipAddressText

        if vpnInfo.detectionStatus == .available, vpnInfo.isEnabled {
            return "🔒 VPN / \(displayIPAddress)"
        }

        if let proxyHost = proxyInfo.menuBarTitleComponent {
            return "🌐 Proxy / \(proxyHost)"
        }

        switch connectionType {
        case .wifi:
            return "🌐 Wi-Fi / \(displayIPAddress)"
        case .ethernet:
            return "🌐 Ethernet / \(displayIPAddress)"
        case .cellular, .other, .unknown:
            return "🌐 Network / \(displayIPAddress)"
        }
    }

    static let placeholder = NetworkInfo(
        isOnline: false,
        connectionType: .unknown,
        globalIPAddress: "未取得",
        localIPAddress: "未取得",
        proxyInfo: .unavailable,
        vpnInfo: .unavailable,
        dns: "未取得",
        isFetchingGlobalIP: false,
        lastUpdated: nil
    )

    private static let lastUpdatedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}
