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
                            viewModel.sourceCrypto = item
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Поиск криптовалюты...")
            .navigationTitle("Котировки")
            .refreshable {
                await viewModel.loadData()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
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
                HStack(spacing: 8) {
                    Text("💎")
                        .font(.title)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(item.symbol)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                PriceChangeBadge(change: item.change24h, isLightStyle: true)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("$\(String(format: "%.3f", item.priceUSD))")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("USDT")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Button(action: onSelect) {
                    Text("В конвертер")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
            Text(item.emoji)
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(Color.subtleBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                Text(item.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(formatPrice(item.priceUSD))
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

    private func formatPrice(_ price: Double) -> String {
        if price >= 1.0 {
            return "$\(String(format: "%.2f", price))"
        } else {
            return "$\(String(format: "%.4f", price))"
        }
    }
}

public struct PriceChangeBadge: View {
    public let change: Double
    public var isLightStyle: Bool = false

    public var isPositive: Bool { change >= 0 }

    public var body: some View {
        HStack(spacing: 2) {
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
