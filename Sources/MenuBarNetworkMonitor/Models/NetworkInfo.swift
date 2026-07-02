import Foundation

struct NetworkInfo: Equatable {
    var connectionStatus: String
    var connectionType: String
    var globalIPAddress: String
    var localIPAddress: String
    var proxy: String
    var vpn: String
    var dns: String
    var lastUpdated: String

    static let placeholder = NetworkInfo(
        connectionStatus: "未取得",
        connectionType: "未取得",
        globalIPAddress: "未取得",
        localIPAddress: "未取得",
        proxy: "未取得",
        vpn: "未取得",
        dns: "未取得",
        lastUpdated: "未取得"
    )
}
