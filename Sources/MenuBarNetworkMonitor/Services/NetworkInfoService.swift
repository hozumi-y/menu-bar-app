import Foundation
import Network

protocol NetworkInfoServicing: AnyObject {
    func fetchNetworkInfo() async -> NetworkInfo
    func startMonitoring(onUpdate: @escaping @Sendable (NetworkInfo) -> Void)
    func stopMonitoring()
}

final class NetworkInfoService: NetworkInfoServicing {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.menubarnetworkmonitor.path-monitor")
    private var isMonitoring = false

    func fetchNetworkInfo() async -> NetworkInfo {
        makeNetworkInfo(from: monitor.currentPath)
    }

    func startMonitoring(onUpdate: @escaping @Sendable (NetworkInfo) -> Void) {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            onUpdate(self.makeNetworkInfo(from: path))
        }

        guard !isMonitoring else {
            onUpdate(makeNetworkInfo(from: monitor.currentPath))
            return
        }

        isMonitoring = true
        monitor.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        guard isMonitoring else { return }
        monitor.cancel()
        isMonitoring = false
    }

    private func makeNetworkInfo(from path: NWPath) -> NetworkInfo {
        NetworkInfo(
            isOnline: path.status == .satisfied,
            connectionType: connectionType(for: path),
            globalIPAddress: "未取得",
            localIPAddress: "未取得",
            proxyInfo: .unavailable,
            vpn: "未取得",
            dns: "未取得",
            isFetchingGlobalIP: false,
            lastUpdated: Date()
        )
    }

    private func connectionType(for path: NWPath) -> ConnectionType {
        guard path.status == .satisfied else { return .unknown }

        if path.usesInterfaceType(.wifi) {
            return .wifi
        }

        if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        }

        if path.usesInterfaceType(.cellular) {
            return .cellular
        }

        if path.usesInterfaceType(.other) || !path.availableInterfaces.isEmpty {
            return .other
        }

        return .unknown
    }
}
