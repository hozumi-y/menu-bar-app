import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: NetworkStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            statusSection
            Divider()
            informationSection
            Divider()
            actionSection
        }
        .padding()
        .frame(width: 360)
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在のステータス")
                .font(.headline)
            Text(viewModel.networkInfo.status.rawValue)
                .font(.title3.bold())
            globalIPRow
        }
    }

    private var globalIPRow: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("グローバルIP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(viewModel.networkInfo.globalIPAddress)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .textSelection(.enabled)
            }
            Spacer()
            Button("コピー") { viewModel.copyGlobalIP() }
        }
    }

    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoRow("ローカルIP", viewModel.networkInfo.localIPAddress)
            infoRow("接続方式", viewModel.networkInfo.connectionType.rawValue)
            infoRow("プロキシ", proxyText)
            if viewModel.networkInfo.proxyInfo.isEnabled {
                infoRow("プロキシ詳細", viewModel.networkInfo.proxyInfo.summary)
            }
            infoRow("VPN", vpnText)
            if viewModel.networkInfo.vpnInfo.isConnected {
                infoRow("VPN詳細", viewModel.networkInfo.vpnInfo.summary)
            }
            infoRow("DNS", viewModel.networkInfo.dnsDisplayText)
            infoRow("最終更新", viewModel.dateFormatter.string(from: viewModel.networkInfo.lastUpdated))
        }
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(viewModel.isRefreshing ? "更新中..." : "更新") {
                Task { await viewModel.refresh() }
            }
            .disabled(viewModel.isRefreshing)
            Button("ローカルIPをコピー") { viewModel.copyLocalIP() }
            Button("ネットワーク情報一式をコピー") { viewModel.copyAllNetworkInfo() }
            Divider()
            Button("アプリ終了") { NSApplication.shared.terminate(nil) }
        }
    }

    private var proxyText: String {
        viewModel.networkInfo.proxyInfo.isEnabled ? "ON" : "OFF"
    }

    private var vpnText: String {
        viewModel.networkInfo.vpnInfo.isConnected ? "ON" : "OFF"
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
        .font(.body)
    }
}
