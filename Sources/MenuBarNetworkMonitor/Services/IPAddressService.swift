import Foundation
import Darwin

protocol IPAddressServicing {
    func fetchGlobalIPAddress() async -> String
    func localIPAddress() -> String
}

final class IPAddressService: IPAddressServicing {
    func fetchGlobalIPAddress() async -> String {
        guard let url = URL(string: "https://api.ipify.org") else { return "取得失敗" }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 8
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !ip.isEmpty else { return "取得失敗" }
            return ip
        } catch {
            return "取得失敗"
        }
    }

    func localIPAddress() -> String {
        var address = "取得不可"
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0, let first = interfaces else { return address }
        defer { freeifaddrs(interfaces) }

        for pointer in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let interface = pointer.pointee
            let flags = Int32(interface.ifa_flags)
            guard (flags & IFF_UP) == IFF_UP, (flags & IFF_LOOPBACK) == 0 else { continue }
            guard interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let result = getnameinfo(interface.ifa_addr,
                                     socklen_t(interface.ifa_addr.pointee.sa_len),
                                     &hostname,
                                     socklen_t(hostname.count),
                                     nil,
                                     0,
                                     NI_NUMERICHOST)
            if result == 0 {
                address = String(cString: hostname)
                break
            }
        }
        return address
    }
}
