import Foundation

enum ProxyDetectionStatus: Equatable {
    case available
    case unavailable
}

struct ProxyInfo: Equatable {
    var isEnabled: Bool
    var type: String
    var host: String
    var port: String
    var detectionStatus: ProxyDetectionStatus

    var statusText: String {
        guard detectionStatus == .available else { return "取得不可" }
        return isEnabled ? "ON" : "OFF"
    }

    var displayHost: String {
        host.isEmpty ? "未取得" : host
    }

    var displayPort: String {
        port.isEmpty ? "未取得" : port
    }

    var summaryText: String {
        guard detectionStatus == .available else { return "取得不可" }
        guard isEnabled else { return "OFF" }

        let endpoint = "\(displayHost):\(displayPort)"
        return "ON / \(type.isEmpty ? "種類未取得" : type) / \(endpoint)"
    }

    static let unavailable = ProxyInfo(
        isEnabled: false,
        type: "",
        host: "",
        port: "",
        detectionStatus: .unavailable
    )

    static let disabled = ProxyInfo(
        isEnabled: false,
        type: "",
        host: "",
        port: "",
        detectionStatus: .available
    )
}
