import SwiftUI

public struct ExchangeCompareView: View {
    @ObservedObject public var viewModel: CryptoViewModel

    public init(viewModel: CryptoViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Spread & Arbitrage summary card
                    if viewModel.arbitrageSpreadPercent > 0 {
                        ArbitrageSummaryCard(
                            spreadPercent: viewModel.arbitrageSpreadPercent,
                            bestBuy: viewModel.bestBuyExchange,
                            bestSell: viewModel.bestSellExchange
                        )
                    }

                    // Tickers per exchange
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Биржевые стаканы (TON/USDT)")
                            .font(.headline)
                            .padding(.horizontal, 4)

                        if viewModel.exchangeTickers.isEmpty {
                            VStack(spacing: 10) {
                                ProgressView()
                                Text("Получение данных с бирж...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        } else {
                            ForEach(viewModel.exchangeTickers) { ticker in
                                ExchangeTickerCard(
                                    ticker: ticker,
                                    isBestBuy: ticker.exchange == viewModel.bestBuyExchange?.exchange,
                                    isBestSell: ticker.exchange == viewModel.bestSellExchange?.exchange
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Биржи TON")
            .refreshable {
                await viewModel.loadData()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task { await viewModel.loadData() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

public struct ArbitrageSummaryCard: View {
    public let spreadPercent: Double
    public let bestBuy: ExchangeTicker?
    public let bestSell: ExchangeTicker?

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Спред между биржами", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
                Spacer()
                Text(String(format: "%.2f%%", spreadPercent))
                    .font(.headline.bold())
                    .foregroundColor(.purple)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.12))
                    .clipShape(Capsule())
            }

            Divider()

            HStack {
                if let bestBuy = bestBuy {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🟢 Купить дешевле:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(bestBuy.exchange) • $\(String(format: "%.4f", bestBuy.price))")
                            .font(.subheadline.bold())
                    }
                }

                Spacer()

                if let bestSell = bestSell {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("🔴 Продать дороже:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(bestSell.exchange) • $\(String(format: "%.4f", bestSell.price))")
                            .font(.subheadline.bold())
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

public struct ExchangeTickerCard: View {
    public let ticker: ExchangeTicker
    public let isBestBuy: Bool
    public let isBestSell: Bool

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticker.exchange)
                        .font(.headline.bold())
                    Text(ticker.pair)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.4f", ticker.price))")
                        .font(.system(.title3, design: .rounded).bold())

                    PriceChangeBadge(change: ticker.change24h)
                }
            }

            // Badges for best prices
            if isBestBuy || isBestSell {
                HStack(spacing: 8) {
                    if isBestBuy {
                        Text("✓ Лучшая покупка")
                            .font(.caption2.bold())
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.green.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    if isBestSell {
                        Text("★ Лучшая продажа")
                            .font(.caption2.bold())
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }

            // Stats row (24h high/low and volume)
            if ticker.high24h > 0 && ticker.low24h > 0 {
                Divider()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("24h Low")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.3f", ticker.low24h))")
                            .font(.caption.bold())
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 2) {
                        Text("24h High")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.3f", ticker.high24h))")
                            .font(.caption.bold())
                    }

                    Spacer()

                    if ticker.volumeUSD > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Объем 24ч")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(formatVolume(ticker.volumeUSD))
                                .font(.caption.bold())
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        )
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return "$\(String(format: "%.1fM", volume / 1_000_000))"
        } else if volume >= 1_000 {
            return "$\(String(format: "%.1fK", volume / 1_000))"
        } else {
            return "$\(Int(volume))"
        }
    }
}
