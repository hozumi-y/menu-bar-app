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
    case unavailable = "取得不可"
}

struct NetworkInfo: Equatable {
    var status: ConnectionStatus = .offline
    var connectionType: ConnectionType = .unavailable
    var localIPAddress: String = "取得不可"
    var globalIPAddress: String = "取得失敗"
    var proxyInfo: ProxyInfo = .unavailable
    var vpnInfo: VPNInfo = VPNInfo(isConnected: false, interfaces: [])
    var dnsServers: [String] = []
    var lastUpdated: Date = Date()

    var dnsDisplayText: String {
        dnsServers.isEmpty ? "取得不可" : dnsServers.joined(separator: ", ")
    }

    var menuBarTitle: String {
        if status == .offline { return "⚠️ Offline" }
        let ip = globalIPAddress.count > 15 ? localIPAddress : globalIPAddress
        if vpnInfo.isConnected { return "🔒 VPN / \(ip)" }
        if proxyInfo.isEnabled { return "🌐 Proxy / \(ip)" }
        return "🌐 \(connectionType.rawValue) / \(ip)"
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
