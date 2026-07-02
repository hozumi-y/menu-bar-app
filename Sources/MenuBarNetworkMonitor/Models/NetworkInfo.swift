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

    var globalIPAddressDisplayText: String {
        if isFetchingGlobalIP { return "取得中" }
        if globalIPAddress == "取得失敗" { return "IP取得失敗" }
        if globalIPAddress.isEmpty { return "未取得" }
        return globalIPAddress
    }

    var dnsDisplayText: String {
        dns.isEmpty ? "未取得" : dns
    }

    var menuBarTitle: String {
        guard isOnline else { return "⚠️ Offline" }

        if vpnInfo.detectionStatus == .available, vpnInfo.isEnabled {
            return "🔒 VPN / \(globalIPAddressDisplayText)"
        }

        if proxyInfo.detectionStatus == .available, proxyInfo.isEnabled {
            return "🌐 Proxy / \(globalIPAddressDisplayText)"
        }

        switch connectionType {
        case .wifi:
            return "🌐 Wi-Fi / \(globalIPAddressDisplayText)"
        case .ethernet:
            return "🌐 Ethernet / \(globalIPAddressDisplayText)"
        case .cellular, .other, .unknown:
            return "🌐 Network / \(globalIPAddressDisplayText)"
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
