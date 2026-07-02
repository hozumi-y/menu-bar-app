import Foundation

enum VPNDetectionStatus: Equatable {
    case available
    case unavailable
}

struct VPNInfo: Equatable {
    var isEnabled: Bool
    var interfaceName: String
    var interfaceNames: [String]
    var detectionStatus: VPNDetectionStatus

    var statusText: String {
        guard detectionStatus == .available else { return "取得不可" }
        return isEnabled ? "ON" : "OFF"
    }

    var displayInterfaceName: String {
        interfaceName.isEmpty ? "未取得" : interfaceName
    }

    var summaryText: String {
        guard detectionStatus == .available else { return "取得不可" }
        guard isEnabled else { return "OFF" }
        return "ON / インターフェース：\(displayInterfaceName)"
    }

    static let unavailable = VPNInfo(
        isEnabled: false,
        interfaceName: "",
        interfaceNames: [],
        detectionStatus: .unavailable
    )

    static let disabled = VPNInfo(
        isEnabled: false,
        interfaceName: "",
        interfaceNames: [],
        detectionStatus: .available
    )
}
