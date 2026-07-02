import SwiftUI

struct NetworkSummaryView: View {
    let networkInfo: NetworkInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("グローバルIP")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(networkInfo.globalIPAddressDisplayText)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                NetworkDetailRow(title: "現在の状態", value: networkInfo.connectionStatusText, valueColor: networkInfo.isOnline ? .green : .orange)
                NetworkDetailRow(title: "ローカルIP", value: networkInfo.localIPAddress)
                NetworkDetailRow(title: "接続方式", value: networkInfo.connectionTypeText)
                NetworkDetailRow(title: "プロキシ", value: networkInfo.proxyInfo.summaryText)
                NetworkDetailRow(title: "VPN", value: networkInfo.vpnInfo.summaryText)
                NetworkDetailRow(title: "DNS", value: networkInfo.dnsDisplayText)
                NetworkDetailRow(title: "最終更新", value: networkInfo.lastUpdatedText)
            }
        }
    }
}
