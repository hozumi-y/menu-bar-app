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
    private let ipAddressService: IPAddressServicing
    private let clipboardService: ClipboardServicing
    private let proxyInfoService: ProxyInfoServicing
    private var refreshTask: Task<Void, Never>?

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        ipAddressService: IPAddressServicing = IPAddressService(),
        clipboardService: ClipboardServicing = ClipboardService(),
        proxyInfoService: ProxyInfoServicing = ProxyInfoService()
    ) {
        self.networkInfo = .placeholder
        self.networkInfoService = networkInfoService
        self.ipAddressService = ipAddressService
        self.clipboardService = clipboardService
        self.proxyInfoService = proxyInfoService
        startMonitoringNetworkStatus()

        Task { await refresh() }
    }

    deinit {
        refreshTask?.cancel()
        networkInfoService.stopMonitoring()
    }

    func refresh() async {
        refreshTask?.cancel()
        isRefreshing = true

        let baseNetworkInfo = await networkInfoService.fetchNetworkInfo()
        await updateIPAddress(for: baseNetworkInfo)

        isRefreshing = false
    }

    func copySummary() {
        clipboardService.copy(networkInfo.summaryText)
    }

    private func startMonitoringNetworkStatus() {
        networkInfoService.startMonitoring { [weak self] networkInfo in
            Task { @MainActor [weak self] in
                self?.refreshTask?.cancel()
                self?.refreshTask = Task { [weak self] in
                    await self?.updateIPAddress(for: networkInfo)
                }
            }
        }
    }

    private func updateIPAddress(for baseNetworkInfo: NetworkInfo) async {
        let localIPAddress = ipAddressService.getLocalIPAddress()
        let proxyInfo = proxyInfoService.getProxyInfo()
        var updatedNetworkInfo = baseNetworkInfo
        updatedNetworkInfo.localIPAddress = localIPAddress
        updatedNetworkInfo.proxyInfo = proxyInfo
        updatedNetworkInfo.globalIPAddress = baseNetworkInfo.isOnline ? "取得中" : "取得失敗"
        updatedNetworkInfo.isFetchingGlobalIP = baseNetworkInfo.isOnline
        updatedNetworkInfo.lastUpdated = Date()
        networkInfo = updatedNetworkInfo

        guard baseNetworkInfo.isOnline else { return }

        let globalIPAddress = await ipAddressService.fetchGlobalIPAddress()
        guard !Task.isCancelled else { return }

        updatedNetworkInfo.globalIPAddress = globalIPAddress
        updatedNetworkInfo.isFetchingGlobalIP = false
        updatedNetworkInfo.lastUpdated = Date()
        networkInfo = updatedNetworkInfo
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
        プロキシ：\(proxyInfo.summaryText)
        VPN：\(vpn)
        DNS：\(dns)
        最終更新：\(lastUpdatedText)
        """
    }
}


private extension ProxyInfo {
    var summaryText: String {
        guard detectionStatus == .available else { return "取得不可" }
        guard isEnabled else { return "OFF" }

        return "ON / 種類：\(type) / ホスト：\(displayHost) / ポート：\(displayPort)"
    }
}
