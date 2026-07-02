import Foundation

struct VPNInfo: Equatable {
    let isConnected: Bool
    let interfaces: [String]

    var summary: String {
        isConnected ? interfaces.joined(separator: ", ") : "OFF"
    }
}
