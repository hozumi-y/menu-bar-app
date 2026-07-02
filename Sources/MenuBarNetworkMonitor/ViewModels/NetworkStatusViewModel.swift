import Combine
import Foundation

@MainActor
final class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkInfo: NetworkInfo
    @Published private(set) var isRefreshing = false

    private let networkInfoService: NetworkInfoServicing
    private let clipboardService: ClipboardServicing

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        clipboardService: ClipboardServicing = ClipboardService()
    ) {
        self.networkInfo = .placeholder
        self.networkInfoService = networkInfoService
        self.clipboardService = clipboardService
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        networkInfo = await networkInfoService.fetchNetworkInfo()
        isRefreshing = false
    }

    func copySummary() {
        clipboardService.copy(networkInfo.summaryText)
    }
}

private extension NetworkInfo {
    var summaryText: String {
        """
        Network Monitor
        接続状態：\(connectionStatus)
        接続方式：\(connectionType)
        グローバルIP：\(globalIPAddress)
        ローカルIP：\(localIPAddress)
        プロキシ：\(proxy)
        VPN：\(vpn)
        DNS：\(dns)
        最終更新：\(lastUpdated)
        """
    }
}
