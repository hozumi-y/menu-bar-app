import Foundation
import SystemConfiguration

protocol ProxyInfoServicing {
    func currentProxyInfo() -> ProxyInfo
}

final class ProxyInfoService: ProxyInfoServicing {
    func currentProxyInfo() -> ProxyInfo {
        guard let proxySettings = SCDynamicStoreCopyProxies(nil)?.takeRetainedValue() as? [String: Any] else {
            return .unavailable
        }

        var endpoints: [ProxyEndpoint] = []
        appendProxy(type: "HTTP", enabledKey: kSCPropNetProxiesHTTPEnable as String, hostKey: kSCPropNetProxiesHTTPProxy as String, portKey: kSCPropNetProxiesHTTPPort as String, settings: proxySettings, to: &endpoints)
        appendProxy(type: "HTTPS", enabledKey: kSCPropNetProxiesHTTPSEnable as String, hostKey: kSCPropNetProxiesHTTPSProxy as String, portKey: kSCPropNetProxiesHTTPSPort as String, settings: proxySettings, to: &endpoints)
        appendProxy(type: "SOCKS", enabledKey: kSCPropNetProxiesSOCKSEnable as String, hostKey: kSCPropNetProxiesSOCKSProxy as String, portKey: kSCPropNetProxiesSOCKSPort as String, settings: proxySettings, to: &endpoints)

        return ProxyInfo(isEnabled: !endpoints.isEmpty, endpoints: endpoints, errorMessage: nil)
    }

    private func appendProxy(type: String, enabledKey: String, hostKey: String, portKey: String, settings: [String: Any], to endpoints: inout [ProxyEndpoint]) {
        guard (settings[enabledKey] as? NSNumber)?.boolValue == true else { return }
        let host = (settings[hostKey] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "未設定"
        let port = (settings[portKey] as? NSNumber)?.intValue ?? 0
        endpoints.append(ProxyEndpoint(type: type, host: host, port: port))
    }
}
