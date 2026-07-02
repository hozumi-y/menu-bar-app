import Foundation
import Darwin

protocol VPNInfoServicing {
    func currentVPNInfo() -> VPNInfo
}

final class VPNInfoService: VPNInfoServicing {
    private let vpnNameHints = ["utun", "ppp", "ipsec", "vpn"]

    func currentVPNInfo() -> VPNInfo {
        var matchedInterfaces: [String] = []
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0, let first = interfaces else {
            return VPNInfo(isConnected: false, interfaces: [])
        }
        defer { freeifaddrs(interfaces) }

        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = pointer.pointee
            let flags = Int32(interface.ifa_flags)
            guard (flags & IFF_UP) == IFF_UP else { continue }
            let name = String(cString: interface.ifa_name).lowercased()
            if vpnNameHints.contains(where: { name.contains($0) }) {
                matchedInterfaces.append(name)
            }
        }

        return VPNInfo(isConnected: !matchedInterfaces.isEmpty, interfaces: Array(Set(matchedInterfaces)).sorted())
    }
}
