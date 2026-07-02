import Foundation

protocol NetworkInfoServicing {
    func fetchNetworkInfo() async -> NetworkInfo
}

final class NetworkInfoService: NetworkInfoServicing {
    func fetchNetworkInfo() async -> NetworkInfo {
        // Step1では実際のネットワーク取得は行わず、仮データを返す。
        .placeholder
    }
}
