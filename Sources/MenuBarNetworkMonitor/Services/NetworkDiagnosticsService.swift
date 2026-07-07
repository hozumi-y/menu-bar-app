import Darwin
import Foundation
import Network

struct NetworkDiagnosticsReport: Equatable {
    var isOnline: Bool
    var localIPAddress: String
    var proxyInfo: ProxyInfo
    var vpnInfo: VPNInfo
    var dnsResults: [DNSDiagnosticResult]
    var internetConnection: InternetConnectionDiagnosticResult
    var apiResults: [GlobalIPAPIDiagnosticResult]
    var causeCandidates: [String]
    var completedAt: Date

    var globalIPDiagnosisText: String {
        apiResults.contains(where: { $0.isSuccessful }) ? "グローバルIP取得成功" : "グローバルIP取得失敗"
    }
}

struct DNSDiagnosticResult: Identifiable, Equatable {
    let id = UUID()
    var host: String
    var isSuccessful: Bool
    var error: String?
}

struct InternetConnectionDiagnosticResult: Equatable {
    var url: URL
    var status: InternetConnectionStatus
    var httpStatus: Int?
    var error: String?
}

enum InternetConnectionStatus: String, Equatable {
    case success = "Success"
    case timeout = "Timeout"
    case sslError = "SSL Error"
    case connectionFailed = "Connection Failed"
}

struct GlobalIPAPIDiagnosticResult: Identifiable, Equatable {
    let id = UUID()
    var url: URL
    var httpStatus: Int?
    var response: String?
    var error: String?
    var timedOut: Bool

    var isSuccessful: Bool {
        guard let httpStatus else { return false }
        return (200..<300).contains(httpStatus) && !(response ?? "").isEmpty
    }
}

protocol NetworkDiagnosticsServicing: AnyObject {
    func runDiagnostics() async -> NetworkDiagnosticsReport
}

final class NetworkDiagnosticsService: NetworkDiagnosticsServicing {
    private let networkInfoService: NetworkInfoServicing
    private let ipAddressService: IPAddressServicing
    private let proxyInfoService: ProxyInfoServicing
    private let vpnInfoService: VPNInfoServicing
    private let urlSession: URLSession
    private let dnsHosts = ["google.com", "api.ipify.org"]
    private let internetCheckURL = URL(string: "https://www.google.com")!
    private let globalIPAPIURLs = [
        URL(string: "https://api.ipify.org")!,
        URL(string: "https://checkip.amazonaws.com")!,
        URL(string: "https://ipv4.icanhazip.com")!
    ]

    init(
        networkInfoService: NetworkInfoServicing = NetworkInfoService(),
        ipAddressService: IPAddressServicing = IPAddressService(),
        proxyInfoService: ProxyInfoServicing = ProxyInfoService(),
        vpnInfoService: VPNInfoServicing = VPNInfoService(),
        urlSession: URLSession = NetworkDiagnosticsService.makeURLSession()
    ) {
        self.networkInfoService = networkInfoService
        self.ipAddressService = ipAddressService
        self.proxyInfoService = proxyInfoService
        self.vpnInfoService = vpnInfoService
        self.urlSession = urlSession
    }

    func runDiagnostics() async -> NetworkDiagnosticsReport {
        async let networkInfo = networkInfoService.fetchNetworkInfo()
        async let dnsResults = resolveDNSHosts()
        async let internetConnection = checkInternetConnection()
        async let apiResults = diagnoseGlobalIPAPIs()

        let localIPAddress = ipAddressService.getLocalIPAddress()
        let proxyInfo = proxyInfoService.getProxyInfo()
        let vpnInfo = vpnInfoService.getVPNInfo()
        let resolvedNetworkInfo = await networkInfo
        let resolvedDNSResults = await dnsResults
        let resolvedInternetConnection = await internetConnection
        let resolvedAPIResults = await apiResults

        let report = NetworkDiagnosticsReport(
            isOnline: resolvedNetworkInfo.isOnline,
            localIPAddress: localIPAddress,
            proxyInfo: proxyInfo,
            vpnInfo: vpnInfo,
            dnsResults: resolvedDNSResults,
            internetConnection: resolvedInternetConnection,
            apiResults: resolvedAPIResults,
            causeCandidates: [],
            completedAt: Date()
        )

        return NetworkDiagnosticsReport(
            isOnline: report.isOnline,
            localIPAddress: report.localIPAddress,
            proxyInfo: report.proxyInfo,
            vpnInfo: report.vpnInfo,
            dnsResults: report.dnsResults,
            internetConnection: report.internetConnection,
            apiResults: report.apiResults,
            causeCandidates: makeCauseCandidates(from: report),
            completedAt: report.completedAt
        )
    }

    private func resolveDNSHosts() async -> [DNSDiagnosticResult] {
        dnsHosts.map { host in
            var hints = addrinfo(ai_flags: 0, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: IPPROTO_TCP, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
            var result: UnsafeMutablePointer<addrinfo>?
            let status = getaddrinfo(host, nil, &hints, &result)
            if let result { freeaddrinfo(result) }
            return DNSDiagnosticResult(host: host, isSuccessful: status == 0, error: status == 0 ? nil : String(cString: gai_strerror(status)))
        }
    }

    private func checkInternetConnection() async -> InternetConnectionDiagnosticResult {
        var request = URLRequest(url: internetCheckURL)
        request.timeoutInterval = 8
        do {
            let (_, response) = try await urlSession.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode
            return InternetConnectionDiagnosticResult(url: internetCheckURL, status: .success, httpStatus: status, error: nil)
        } catch {
            let mapped = mapInternetConnectionError(error)
            return InternetConnectionDiagnosticResult(url: internetCheckURL, status: mapped.status, httpStatus: nil, error: mapped.message)
        }
    }

    private func diagnoseGlobalIPAPIs() async -> [GlobalIPAPIDiagnosticResult] {
        var results: [GlobalIPAPIDiagnosticResult] = []
        for url in globalIPAPIURLs {
            var request = URLRequest(url: url)
            request.timeoutInterval = 8
            do {
                let (data, response) = try await urlSession.data(for: request)
                let httpStatus = (response as? HTTPURLResponse)?.statusCode
                let body = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                let error = httpStatus.map { (200..<300).contains($0) ? nil : "HTTP \($0)" } ?? "HTTP Status取得失敗"
                results.append(GlobalIPAPIDiagnosticResult(url: url, httpStatus: httpStatus, response: body, error: error, timedOut: false))
            } catch {
                let nsError = error as NSError
                results.append(GlobalIPAPIDiagnosticResult(url: url, httpStatus: nil, response: nil, error: describe(error), timedOut: nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut))
            }
        }
        return results
    }

    private func makeCauseCandidates(from report: NetworkDiagnosticsReport) -> [String] {
        var candidates: [String] = []
        if !report.isOnline { candidates.append("ネットワークオフライン") }
        if report.localIPAddress == "取得不可" { candidates.append("ローカルIP取得失敗") }
        if report.proxyInfo.isEnabled { candidates.append("Proxy接続失敗または認証失敗") }
        if report.vpnInfo.isEnabled { candidates.append("VPN経路またはDNS設定の問題") }
        if report.dnsResults.contains(where: { !$0.isSuccessful }) { candidates.append("DNS解決失敗") }
        if report.internetConnection.status == .timeout || report.apiResults.contains(where: { $0.timedOut }) { candidates.append("外部APIタイムアウト") }
        if report.internetConnection.status == .sslError || report.apiResults.contains(where: { ($0.error ?? "").contains("SSL") }) { candidates.append("SSL Error") }
        if report.internetConnection.status == .connectionFailed { candidates.append("インターネット接続失敗") }
        if report.apiResults.contains(where: { ($0.httpStatus ?? 200) >= 400 }) { candidates.append("APIサーバーHTTPエラー") }
        if report.apiResults.contains(where: { ($0.error ?? "").localizedCaseInsensitiveContains("SOCKS") }) { candidates.append("SOCKS Proxy認証失敗") }
        return candidates.isEmpty ? ["明確な原因は検出できませんでした"] : candidates
    }

    private func mapInternetConnectionError(_ error: Error) -> (status: InternetConnectionStatus, message: String) {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return (.connectionFailed, describe(error)) }
        switch nsError.code {
        case NSURLErrorTimedOut:
            return (.timeout, describe(error))
        case NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateUntrusted, NSURLErrorServerCertificateHasUnknownRoot, NSURLErrorServerCertificateNotYetValid, NSURLErrorClientCertificateRejected, NSURLErrorClientCertificateRequired:
            return (.sslError, describe(error))
        default:
            return (.connectionFailed, describe(error))
        }
    }

    private func describe(_ error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut: return "Timed Out (\(nsError.localizedDescription))"
            case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed: return "DNS Lookup Failed (\(nsError.localizedDescription))"
            case NSURLErrorCannotConnectToHost: return "Cannot Connect To Host (\(nsError.localizedDescription))"
            case NSURLErrorSecureConnectionFailed: return "SSL Error (\(nsError.localizedDescription))"
            default: break
            }
        }
        return "\(nsError.localizedDescription) [domain: \(nsError.domain), code: \(nsError.code)]"
    }

    private static func makeURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 12
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }
}
