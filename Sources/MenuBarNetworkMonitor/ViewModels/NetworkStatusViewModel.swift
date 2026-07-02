import Combine
import Foundation

@MainActor
final class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkInfo: NetworkInfo
    @Published private(set) var isRefreshing = false

    var menuBarTitle: String {
        networkInfo.menuBarTitle
    }

    private let networkInfoService: NetworkInfoServicing
    private let clipboardService: ClipboardServicing

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        clipboardService: ClipboardServicing = ClipboardService()
    ) {
        self.networkInfo = .placeholder
        self.networkInfoService = networkInfoService
        self.clipboardService = clipboardService
        startMonitoringNetworkStatus()
    }

    deinit {
        networkInfoService.stopMonitoring()
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

    private func startMonitoringNetworkStatus() {
        networkInfoService.startMonitoring { [weak self] networkInfo in
            Task { @MainActor [weak self] in
                self?.networkInfo = networkInfo
            }
        }
    }
}

private extension NetworkInfo {
    var summaryText: String {
        """
        Network Monitor
        接続状態：\(connectionStatusText)
        接続方式：\(connectionTypeText)
        グローバルIP：\(globalIPAddress)
        ローカルIP：\(localIPAddress)
        プロキシ：\(proxy)
        VPN：\(vpn)
        DNS：\(dns)
        最終更新：\(lastUpdatedText)
        """
    }
}
