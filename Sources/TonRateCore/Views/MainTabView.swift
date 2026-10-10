import SwiftUI

public struct MainTabView: View {
    @StateObject private var viewModel = CryptoViewModel()

    public init() {}

    public var body: some View {
        TabView {
            ConverterView(viewModel: viewModel)
                .tabItem {
                    Label("Конвертер", systemImage: "arrow.triangle.swap")
                }

            MarketRatesView(viewModel: viewModel)
                .tabItem {
                    Label("Курсы", systemImage: "chart.bar.xaxis")
                }

            ExchangeCompareView(viewModel: viewModel)
                .tabItem {
                    Label("Биржи TON", systemImage: "building.columns")
                }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
