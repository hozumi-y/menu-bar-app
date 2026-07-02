import Darwin
import Foundation

protocol VPNInfoServicing: AnyObject {
    func getVPNInfo() -> VPNInfo
}

final class VPNInfoService: VPNInfoServicing {
    private let vpnInterfaceKeywords = ["utun", "ppp", "ipsec", "vpn", "tap", "tun"]

    func getVPNInfo() -> VPNInfo {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&interfaceAddresses) == 0, let firstInterfaceAddress = interfaceAddresses else {
            return .unavailable
        }

        defer { freeifaddrs(interfaceAddresses) }

        var detectedInterfaceNames: [String] = []
        var currentInterfaceAddress: UnsafeMutablePointer<ifaddrs>? = firstInterfaceAddress

        while let interfaceAddress = currentInterfaceAddress {
            let interface = interfaceAddress.pointee

            if let namePointer = interface.ifa_name {
                let interfaceName = String(cString: namePointer)
                let normalizedInterfaceName = interfaceName.lowercased()

                if vpnInterfaceKeywords.contains(where: { normalizedInterfaceName.contains($0) }),
                   !detectedInterfaceNames.contains(interfaceName) {
                    detectedInterfaceNames.append(interfaceName)
                }
            }

            currentInterfaceAddress = interface.ifa_next
        }

        guard let primaryInterfaceName = detectedInterfaceNames.first else {
            return .disabled
        }

        return VPNInfo(
            isEnabled: true,
            interfaceName: primaryInterfaceName,
            interfaceNames: detectedInterfaceNames,
            detectionStatus: .available
        )
    }
}
