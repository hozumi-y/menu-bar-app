import Foundation
import Network

protocol NetworkInfoServicing: AnyObject {
    var onUpdate: ((NetworkInfo) -> Void)? { get set }

    func startMonitoring()
    func fetchNetworkInfo() async -> NetworkInfo
}

final class NetworkInfoService: NetworkInfoServicing {
    var onUpdate: ((NetworkInfo) -> Void)?

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkInfoService.NWPathMonitor")
    private var latestPath: NWPath?

    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor
    }

    deinit {
        monitor.cancel()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.latestPath = path
            self.onUpdate?(self.makeNetworkInfo(from: path))
        }
        monitor.start(queue: queue)
    }

    func fetchNetworkInfo() async -> NetworkInfo {
        makeNetworkInfo(from: latestPath ?? monitor.currentPath)
    }

    private func makeNetworkInfo(from path: NWPath) -> NetworkInfo {
        NetworkInfo(
            isOnline: path.status == .satisfied,
            connectionType: connectionType(for: path),
            globalIPAddress: "未取得",
            localIPAddress: "未取得",
            proxy: "未取得",
            vpn: "未取得",
            dns: "未取得",
            lastUpdated: Date()
        )
    }

    private func connectionType(for path: NWPath) -> NetworkConnectionType {
        guard path.status == .satisfied else { return .unknown }

        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.other) { return .other }
        return .unknown
    }
}
