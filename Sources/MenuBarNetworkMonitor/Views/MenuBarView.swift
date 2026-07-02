import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: NetworkStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Network Monitor")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                infoRow(title: "接続状態", value: viewModel.networkInfo.connectionStatusText)
                infoRow(title: "接続方式", value: viewModel.networkInfo.connectionTypeText)
                infoRow(title: "グローバルIP", value: viewModel.networkInfo.globalIPAddress)
                infoRow(title: "ローカルIP", value: viewModel.networkInfo.localIPAddress)
                infoRow(title: "プロキシ", value: viewModel.networkInfo.proxy)
                infoRow(title: "VPN", value: viewModel.networkInfo.vpn)
                infoRow(title: "DNS", value: viewModel.networkInfo.dns)
                infoRow(title: "最終更新", value: viewModel.lastUpdatedText)
            }

            Divider()

            Button(viewModel.isRefreshing ? "更新中..." : "更新") {
                Task { await viewModel.refresh() }
            }
            .disabled(viewModel.isRefreshing)

            Button("アプリを終了") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 320, alignment: .leading)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(title)：")
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
