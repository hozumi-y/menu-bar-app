import SwiftUI

struct NetworkDiagnosticsView: View {
    @ObservedObject var viewModel: NetworkStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ネットワーク診断")
                    .font(.headline)
                Spacer()
                Button("再診断") {
                    viewModel.runDiagnostics()
                }
                .disabled(viewModel.isRunningDiagnostics)
            }

            if viewModel.isRunningDiagnostics {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("診断中...")
                        .foregroundStyle(.secondary)
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let report = viewModel.diagnosticsReport {
                        diagnosticsReportView(report)
                    } else if !viewModel.isRunningDiagnostics {
                        Text("ネットワーク診断ボタンを押すと診断を開始します。")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 420)
        }
        .padding(16)
        .frame(width: 520, minHeight: 420, alignment: .topLeading)
        .onAppear {
            if viewModel.diagnosticsReport == nil {
                viewModel.runDiagnostics()
            }
        }
    }

    @ViewBuilder
    private func diagnosticsReportView(_ report: NetworkDiagnosticsReport) -> some View {
        diagnosticSection("1. ネットワーク接続") {
            diagnosticRow("状態", report.isOnline ? "オンライン" : "オフライン")
        }

        diagnosticSection("2. ローカルIP取得") {
            diagnosticRow("結果", report.localIPAddress == "取得不可" ? "失敗" : "成功")
            diagnosticRow("IP", report.localIPAddress)
        }

        diagnosticSection("3. プロキシ状態") {
            diagnosticRow("状態", report.proxyInfo.statusText)
            diagnosticRow("種類", report.proxyInfo.type.isEmpty ? "未取得" : report.proxyInfo.type)
            diagnosticRow("Host", report.proxyInfo.displayHost)
            diagnosticRow("Port", report.proxyInfo.displayPort)
        }

        diagnosticSection("4. VPN") {
            diagnosticRow("状態", report.vpnInfo.statusText)
            if report.vpnInfo.isEnabled {
                diagnosticRow("Interface", report.vpnInfo.displayInterfaceName)
            }
        }

        diagnosticSection("5. DNS解決") {
            ForEach(report.dnsResults) { result in
                diagnosticRow(result.host, result.isSuccessful ? "成功" : "失敗")
                if let error = result.error {
                    diagnosticRow("Error", error)
                }
            }
        }

        diagnosticSection("6. インターネット接続確認") {
            diagnosticRow("URL", report.internetConnection.url.absoluteString)
            diagnosticRow("結果", report.internetConnection.status.rawValue)
            if let httpStatus = report.internetConnection.httpStatus {
                diagnosticRow("HTTP Status", String(httpStatus))
            }
            if let error = report.internetConnection.error {
                diagnosticRow("Error", error)
            }
        }

        diagnosticSection("7. グローバルIP取得API診断") {
            ForEach(report.apiResults) { result in
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.url.absoluteString)
                        .font(.subheadline.weight(.semibold))
                    diagnosticRow("HTTP Status", result.httpStatus.map(String.init) ?? "未取得")
                    diagnosticRow("Response", result.response ?? "未取得")
                    diagnosticRow("Error", result.error ?? "なし")
                    diagnosticRow("Timeout", result.timedOut ? "Timeout" : "なし")
                }
                .padding(.bottom, 6)
            }
        }

        diagnosticSection("診断結果") {
            Text(report.globalIPDiagnosisText)
                .font(.subheadline.weight(.semibold))
            Text("原因候補")
                .font(.subheadline.weight(.semibold))
            ForEach(report.causeCandidates, id: \.self) { candidate in
                Text("・\(candidate)")
            }
        }
    }

    private func diagnosticSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            content()
        }
    }

    private func diagnosticRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption)
    }
}
