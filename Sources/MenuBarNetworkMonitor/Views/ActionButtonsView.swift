import AppKit
import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: NetworkStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(viewModel.isRefreshing ? "更新中..." : "更新") {
                Task { await viewModel.refresh() }
            }
            .disabled(viewModel.isRefreshing)

            Button("グローバルIPをコピー") {
                viewModel.copyGlobalIPAddress()
            }

            Button("ローカルIPをコピー") {
                viewModel.copyLocalIPAddress()
            }

            Button("ネットワーク情報をコピー") {
                viewModel.copyNetworkInfo()
            }

            if let copyMessage = viewModel.copyMessage {
                Text(copyMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            Button("アプリを終了") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
