import Combine
import Foundation

@MainActor
final class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkInfo: NetworkInfo
    @Published private(set) var isRefreshing = false

    private let networkInfoService: NetworkInfoServicing
    private let clipboardService: ClipboardServicing
    private let dateFormatter: DateFormatter

    var menuBarTitle: String {
        networkInfo.menuBarTitle
    }

    var lastUpdatedText: String {
        guard let lastUpdated = networkInfo.lastUpdated else { return "未取得" }
        return dateFormatter.string(from: lastUpdated)
    }

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        clipboardService: ClipboardServicing = ClipboardService()
    ) {
        self.networkInfo = .placeholder
        self.networkInfoService = networkInfoService
        self.clipboardService = clipboardService
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        self.networkInfoService.onUpdate = { [weak self] networkInfo in
            Task { @MainActor in
                self?.networkInfo = networkInfo
            }
        }
        self.networkInfoService.startMonitoring()

        Task { await refresh() }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        networkInfo = await networkInfoService.fetchNetworkInfo()
        isRefreshing = false
    }

    func copySummary() {
        clipboardService.copy(summaryText)
    }

    private var summaryText: String {
        """
        Network Monitor
        接続状態：\(networkInfo.connectionStatusText)
        接続方式：\(networkInfo.connectionTypeText)
        グローバルIP：\(networkInfo.globalIPAddress)
        ローカルIP：\(networkInfo.localIPAddress)
        プロキシ：\(networkInfo.proxy)
        VPN：\(networkInfo.vpn)
        DNS：\(networkInfo.dns)
        最終更新：\(lastUpdatedText)
        """
    }
}
