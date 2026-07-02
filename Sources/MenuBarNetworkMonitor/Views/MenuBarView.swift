import SwiftUI

struct MenuBarView: View {
    @ObservedObject var viewModel: NetworkStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Network Monitor")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            NetworkSummaryView(networkInfo: viewModel.networkInfo)

            Divider()

            ActionButtonsView(viewModel: viewModel)
        }
        .padding(16)
        .frame(width: 340, alignment: .leading)
    }
}
