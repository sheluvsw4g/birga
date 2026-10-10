import SwiftUI

public struct MarketRatesView: View {
    @ObservedObject public var viewModel: CryptoViewModel
    @State private var searchText: String = ""

    public init(viewModel: CryptoViewModel) {
        self.viewModel = viewModel
    }

    private var filteredCryptos: [CryptoItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewModel.cryptos
        }
        return viewModel.cryptos.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.symbol.localizedCaseInsensitiveContains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                // TON Spotlight Hero Section
                if let ton = viewModel.cryptos.first(where: { $0.symbol == "TON" }) {
                    Section {
                        TonHeroCard(item: ton) {
                            HapticManager.impact(style: .medium)
                            viewModel.sourceCrypto = ton
                            if let usdt = viewModel.cryptos.first(where: { $0.symbol == "USDT" }) {
                                viewModel.targetCrypto = usdt
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                Section("Рыночные котировки") {
                    ForEach(filteredCryptos) { item in
                        CryptoRowView(item: item) {
                            HapticManager.impact(style: .light)
                            viewModel.sourceCrypto = item
                        }
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
            .searchable(text: $searchText, prompt: "Поиск криптовалюты...")
            .navigationTitle("Котировки")
            .refreshable {
                HapticManager.impact(style: .medium)
                await viewModel.loadData()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        HapticManager.impact(style: .light)
                        Task { await viewModel.loadData() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                #if os(macOS)
                                .scaleEffect(0.7)
                                #endif
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
    }
}

public struct TonHeroCard: View {
    public let item: CryptoItem
    public let onSelect: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 10) {
                    CryptoIconView(symbol: "TON", size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Binance Spot")
                            .font(.caption2.bold())
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                PriceChangeBadge(change: item.change24h, isLightStyle: true)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("$\(String(format: "%.4f", item.priceUSD))")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("USDT")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Button(action: onSelect) {
                    Text("В конвертер")
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if item.high24h > 0 && item.low24h > 0 {
                HStack {
                    Text("24h Min: $\(String(format: "%.4f", item.low24h))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.75))
                    Spacer()
                    Text("24h Max: $\(String(format: "%.4f", item.high24h))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.75))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

public struct CryptoRowView: View {
    public let item: CryptoItem
    public let onSelect: () -> Void

    public var body: some View {
        HStack(spacing: 12) {
            CryptoIconView(symbol: item.symbol, size: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                Text(item.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(formatExactPrice(item.priceUSD))
                    .font(.system(.body, design: .rounded).bold())

                PriceChangeBadge(change: item.change24h)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    private func formatExactPrice(_ price: Double) -> String {
        if price >= 1000.0 {
            return "$\(String(format: "%.2f", price))"
        } else if price >= 1.0 {
            return "$\(String(format: "%.4f", price))"
        } else {
            return "$\(String(format: "%.6f", price))"
        }
    }
}

public struct PriceChangeBadge: View {
    public let change: Double
    public var isLightStyle: Bool = false

    public var isPositive: Bool { change >= 0 }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption2.bold())
            Text(String(format: "%.2f%%", abs(change)))
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundColor(isLightStyle ? .white : (isPositive ? .green : .red))
        .background(
            isLightStyle
                ? Color.white.opacity(0.2)
                : (isPositive ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
        )
        .clipShape(Capsule())
    }
}
