import Darwin
import Foundation

protocol IPAddressServicing: AnyObject {
    func getLocalIPAddress() -> String
    func fetchGlobalIPAddress() async -> String
}

final class IPAddressService: IPAddressServicing {
    private let globalIPProviders: [URL]
    private let urlSession: URLSession

    init(
        globalIPProviders: [URL] = [
            URL(string: "https://api.ipify.org")!,
            URL(string: "https://ipv4.icanhazip.com")!,
            URL(string: "https://checkip.amazonaws.com")!
        ],
        urlSession: URLSession = .shared
    ) {
        self.globalIPProviders = globalIPProviders
        self.urlSession = urlSession
    }

    func getLocalIPAddress() -> String {
        var address: String?
        var interfaces: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&interfaces) == 0, let firstInterface = interfaces else {
            return "取得不可"
        }

        defer { freeifaddrs(interfaces) }

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstInterface
        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }

            let flags = Int32(interface.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isRunning = (flags & IFF_RUNNING) == IFF_RUNNING
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK

            guard isUp, isRunning, !isLoopback,
                  let socketAddress = interface.ifa_addr,
                  socketAddress.pointee.sa_family == UInt8(AF_INET) else {
                continue
            }

            let interfaceName = String(cString: interface.ifa_name)
            let candidate = ipv4Address(from: socketAddress)

            if isPreferredInterface(interfaceName), let candidate {
                return candidate
            }

            address = address ?? candidate
        }

        return address ?? "取得不可"
    }

    func fetchGlobalIPAddress() async -> String {
        for provider in globalIPProviders {
            guard let ipAddress = await fetchIPAddress(from: provider) else {
                continue
            }

            return ipAddress
        }

        return "取得失敗"
    }

    private func fetchIPAddress(from url: URL) async -> String? {
        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return nil
            }

            let value = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let value, isValidIPv4Address(value) else {
                return nil
            }

            return value
        } catch {
            return nil
        }
    }

    private func ipv4Address(from socketAddress: UnsafePointer<sockaddr>) -> String? {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let result = getnameinfo(
            socketAddress,
            socklen_t(socketAddress.pointee.sa_len),
            &hostname,
            socklen_t(hostname.count),
            nil,
            0,
            NI_NUMERICHOST
        )

        guard result == 0 else { return nil }
        return String(cString: hostname)
    }

    private func isPreferredInterface(_ name: String) -> Bool {
        name.hasPrefix("en") || name.hasPrefix("bridge")
    }

    private func isValidIPv4Address(_ value: String) -> Bool {
        var address = in_addr()
        return value.withCString { inet_pton(AF_INET, $0, &address) } == 1
    }
}
