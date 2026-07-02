import Foundation
import SystemConfiguration

protocol ProxyInfoServicing: AnyObject {
    func getProxyInfo() -> ProxyInfo
}

final class ProxyInfoService: ProxyInfoServicing {
    func getProxyInfo() -> ProxyInfo {
        guard let proxies = SCDynamicStoreCopyProxies(nil) as NSDictionary? else {
            return .unavailable
        }

        return proxyInfo(
            from: proxies,
            enabledKey: kSCPropNetProxiesSOCKSEnable,
            hostKey: kSCPropNetProxiesSOCKSProxy,
            portKey: kSCPropNetProxiesSOCKSPort,
            type: "SOCKS"
        ) ?? proxyInfo(
            from: proxies,
            enabledKey: kSCPropNetProxiesHTTPSEnable,
            hostKey: kSCPropNetProxiesHTTPSProxy,
            portKey: kSCPropNetProxiesHTTPSPort,
            type: "HTTPS"
        ) ?? proxyInfo(
            from: proxies,
            enabledKey: kSCPropNetProxiesHTTPEnable,
            hostKey: kSCPropNetProxiesHTTPProxy,
            portKey: kSCPropNetProxiesHTTPPort,
            type: "HTTP"
        ) ?? .disabled
    }

    private func proxyInfo(
        from proxies: NSDictionary,
        enabledKey: CFString,
        hostKey: CFString,
        portKey: CFString,
        type: String
    ) -> ProxyInfo? {
        guard isProxyEnabled(proxies[enabledKey]) else { return nil }

        let host = stringValue(from: proxies[hostKey])

        return ProxyInfo(
            isEnabled: true,
            type: type,
            host: host,
            port: stringValue(from: proxies[portKey]),
            detectionStatus: .available
        )
    }

    private func isProxyEnabled(_ value: Any?) -> Bool {
        switch value {
        case let number as NSNumber:
            return number.boolValue
        case let bool as Bool:
            return bool
        case let string as String:
            return string == "1" || string.lowercased() == "true"
        default:
            return false
        }
    }

    private func stringValue(from value: Any?) -> String {
        switch value {
        case let string as String:
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        case let number as NSNumber:
            return number.stringValue
        default:
            return ""
        }
    }
}
