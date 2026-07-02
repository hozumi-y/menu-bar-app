import Combine
import Foundation

@MainActor
final class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkInfo: NetworkInfo
    @Published private(set) var isRefreshing = false
    @Published private(set) var copyMessage: String?

    var menuBarTitle: String {
        networkInfo.menuBarTitle
    }

    private let networkInfoService: NetworkInfoServicing
    private let ipAddressService: IPAddressServicing
    private let clipboardService: ClipboardServicing
    private let proxyInfoService: ProxyInfoServicing
    private let vpnInfoService: VPNInfoServicing
    private var refreshTask: Task<Void, Never>?
    private var copyMessageTask: Task<Void, Never>?

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        ipAddressService: IPAddressServicing = IPAddressService(),
        clipboardService: ClipboardServicing = ClipboardService(),
        proxyInfoService: ProxyInfoServicing = ProxyInfoService(),
        vpnInfoService: VPNInfoServicing = VPNInfoService()
    ) {
        self.networkInfo = .placeholder
        self.networkInfoService = networkInfoService
        self.ipAddressService = ipAddressService
        self.clipboardService = clipboardService
        self.proxyInfoService = proxyInfoService
        self.vpnInfoService = vpnInfoService
        startMonitoringNetworkStatus()

        Task { await refresh() }
    }

    deinit {
        refreshTask?.cancel()
        networkInfoService.stopMonitoring()
        copyMessageTask?.cancel()
    }

    func refresh() async {
        refreshTask?.cancel()
        isRefreshing = true

        let baseNetworkInfo = await networkInfoService.fetchNetworkInfo()
        await updateIPAddress(for: baseNetworkInfo)

        isRefreshing = false
    }

    func copyGlobalIPAddress() {
        copyToClipboard(networkInfo.globalIPAddressDisplayText)
    }

    func copyLocalIPAddress() {
        copyToClipboard(networkInfo.localIPAddress)
    }

    func copyNetworkInfo() {
        copyToClipboard(networkInfo.clipboardText)
    }

    private func copyToClipboard(_ text: String) {
        let didCopy = clipboardService.copy(text)
        showCopyMessage(didCopy ? "コピーしました" : "コピーできませんでした")
    }

    private func showCopyMessage(_ message: String) {
        copyMessageTask?.cancel()
        copyMessage = message
        copyMessageTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.copyMessage = nil
            }
        }
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
        let vpnInfo = vpnInfoService.getVPNInfo()
        var updatedNetworkInfo = baseNetworkInfo
        updatedNetworkInfo.localIPAddress = localIPAddress
        updatedNetworkInfo.proxyInfo = proxyInfo
        updatedNetworkInfo.vpnInfo = vpnInfo
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
    var clipboardText: String {
        """
        現在のネットワーク情報
        接続状態：\(connectionStatusText)
        接続方式：\(connectionTypeText)
        グローバルIP：\(globalIPAddressDisplayText)
        ローカルIP：\(localIPAddressDisplayText)
        プロキシ：\(proxyInfo.statusText)
        プロキシ種別：\(proxyInfo.typeDisplayText)
        プロキシホスト：\(proxyInfo.displayHost)
        プロキシポート：\(proxyInfo.displayPort)
        VPN：\(vpnInfo.statusText)
        DNS：\(dnsDisplayText)
        最終更新：\(clipboardLastUpdatedText)
        """
    }

    var localIPAddressDisplayText: String {
        localIPAddress.isEmpty ? "未取得" : localIPAddress
    }

    var clipboardLastUpdatedText: String {
        guard let lastUpdated else { return "未取得" }
        return Self.clipboardLastUpdatedFormatter.string(from: lastUpdated)
    }

    private static var clipboardLastUpdatedFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }
}

private extension ProxyInfo {
    var typeDisplayText: String {
        type.isEmpty ? "未取得" : type
    }
}
