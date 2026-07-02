import Foundation

protocol DNSInfoServicing: AnyObject {
    func getDNSInfo() -> String
}

final class DNSInfoService: DNSInfoServicing {
    private let resolverConfigurationPath: String

    init(resolverConfigurationPath: String = "/etc/resolv.conf") {
        self.resolverConfigurationPath = resolverConfigurationPath
    }

    func getDNSInfo() -> String {
        guard let contents = try? String(contentsOfFile: resolverConfigurationPath, encoding: .utf8) else {
            return "取得不可"
        }

        let servers = contents
            .split(whereSeparator: \.isNewline)
            .compactMap { line -> String? in
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedLine.hasPrefix("nameserver") else { return nil }

                return trimmedLine
                    .split(separator: " ")
                    .dropFirst()
                    .first
                    .map(String.init)
            }

        return servers.isEmpty ? "未取得" : servers.joined(separator: ", ")
    }
}
