import Foundation
import Network
import SystemConfiguration

protocol NetworkInfoServicing {
    var pathUpdateHandler: ((NWPath) -> Void)? { get set }
    func startMonitoring()
    func refresh() async -> NetworkInfo
}

final class NetworkInfoService: NetworkInfoServicing {
    var pathUpdateHandler: ((NWPath) -> Void)?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkInfoService.NWPathMonitor")
    private let ipAddressService: IPAddressServicing
    private let proxyInfoService: ProxyInfoServicing
    private let vpnInfoService: VPNInfoServicing
    private var latestPath: NWPath?

    init(ipAddressService: IPAddressServicing = IPAddressService(), proxyInfoService: ProxyInfoServicing = ProxyInfoService(), vpnInfoService: VPNInfoServicing = VPNInfoService()) {
        self.ipAddressService = ipAddressService
        self.proxyInfoService = proxyInfoService
        self.vpnInfoService = vpnInfoService
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.latestPath = path
            self?.pathUpdateHandler?(path)
        }
        monitor.start(queue: queue)
    }

    func refresh() async -> NetworkInfo {
        let path = latestPath ?? monitor.currentPath
        async let globalIP = ipAddressService.fetchGlobalIPAddress()
        let localIP = ipAddressService.localIPAddress()
        let proxy = proxyInfoService.currentProxyInfo()
        let vpn = vpnInfoService.currentVPNInfo()
        let dns = dnsServers()

        return NetworkInfo(
            status: path.status == .satisfied ? .online : .offline,
            connectionType: connectionType(for: path),
            localIPAddress: localIP,
            globalIPAddress: path.status == .satisfied ? await globalIP : "取得失敗",
            proxyInfo: proxy,
            vpnInfo: vpn,
            dnsServers: dns,
            lastUpdated: Date()
        )
    }

    private func connectionType(for path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        if path.usesInterfaceType(.cellular) { return .cellular }
        return path.status == .satisfied ? .other : .unknown
    }

    private func dnsServers() -> [String] {
        guard let store = SCDynamicStoreCreate(nil, "MenuBarNetworkMonitor" as CFString, nil, nil),
              let dictionary = SCDynamicStoreCopyValue(store, "State:/Network/Global/DNS" as CFString) as? [String: Any],
              let addresses = dictionary["ServerAddresses"] as? [String] else {
            return []
        }
        return addresses
    }
}
