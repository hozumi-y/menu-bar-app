import Foundation

enum ConnectionStatus: String {
    case online = "オンライン"
    case offline = "オフライン"
}

enum ConnectionType: String {
    case wifi = "Wi-Fi"
    case ethernet = "Ethernet"
    case cellular = "Cellular"
    case other = "Other"
    case unknown = "Unknown"
}

struct NetworkInfo: Equatable {
    var status: ConnectionStatus = .offline
    var connectionType: ConnectionType = .unknown
    var localIPAddress: String = "取得不可"
    var globalIPAddress: String = "取得失敗"
    var proxyInfo: ProxyInfo = .unavailable
    var vpnInfo: VPNInfo = VPNInfo(isConnected: false, interfaces: [])
    var dnsServers: [String] = []
    var lastUpdated: Date = Date()

    var dnsDisplayText: String {
        dnsServers.isEmpty ? "取得不可" : dnsServers.joined(separator: ", ")
    }

    var connectionStatusText: String {
        status.rawValue
    }

    var menuBarTitle: String {
        guard status == .online else { return "⚠️ Offline" }

        switch connectionType {
        case .wifi:
            return "🌐 Wi-Fi"
        case .ethernet:
            return "🌐 Ethernet"
        case .cellular, .other, .unknown:
            return "🌐 Network"
        }
    }

    func copyText(dateFormatter: DateFormatter) -> String {
        """
        現在のネットワーク情報
        接続状態：\(status.rawValue)
        接続方式：\(connectionType.rawValue)
        ローカルIP：\(localIPAddress)
        グローバルIP：\(globalIPAddress)
        プロキシ：\(proxyInfo.isEnabled ? "ON" : "OFF")
        VPN：\(vpnInfo.isConnected ? "ON" : "OFF")
        DNS：\(dnsDisplayText)
        最終更新：\(dateFormatter.string(from: lastUpdated))
        """
    }
}
