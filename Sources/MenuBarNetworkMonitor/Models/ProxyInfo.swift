import Foundation

struct ProxyEndpoint: Identifiable, Equatable {
    let id = UUID()
    let type: String
    let host: String
    let port: Int

    var displayText: String { "\(type): \(host):\(port)" }
}

struct ProxyInfo: Equatable {
    let isEnabled: Bool
    let endpoints: [ProxyEndpoint]
    let errorMessage: String?

    static let unavailable = ProxyInfo(isEnabled: false, endpoints: [], errorMessage: "取得不可")

    var summary: String {
        guard isEnabled else { return errorMessage ?? "OFF" }
        return endpoints.map(\.displayText).joined(separator: " / ")
    }
}
