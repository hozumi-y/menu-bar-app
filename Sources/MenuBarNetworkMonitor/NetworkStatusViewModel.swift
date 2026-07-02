import Foundation
import Network

@MainActor
final class NetworkStatusViewModel: ObservableObject {
    @Published private(set) var networkInfo = NetworkInfo()
    @Published private(set) var isRefreshing = false

    private let networkInfoService: NetworkInfoServicing
    private let clipboardService: ClipboardServicing
    let dateFormatter: DateFormatter

    init(networkInfoService: NetworkInfoServicing = NetworkInfoService(), clipboardService: ClipboardServicing = ClipboardService()) {
        self.networkInfoService = networkInfoService
        self.clipboardService = clipboardService
        self.dateFormatter = DateFormatter()
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"

        self.networkInfoService.pathUpdateHandler = { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
        self.networkInfoService.startMonitoring()

        Task { await refresh() }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        networkInfo = await networkInfoService.refresh()
        isRefreshing = false
    }

    func copyGlobalIP() {
        clipboardService.copy(networkInfo.globalIPAddress)
    }

    func copyLocalIP() {
        clipboardService.copy(networkInfo.localIPAddress)
    }

    func copyAllNetworkInfo() {
        clipboardService.copy(networkInfo.copyText(dateFormatter: dateFormatter))
    }
}
