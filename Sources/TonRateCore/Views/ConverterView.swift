import SwiftUI

public struct ConverterView: View {
    @ObservedObject public var viewModel: CryptoViewModel
    @State private var swapRotation: Double = 0
    @State private var isAnimatingResult: Bool = false

    public init(viewModel: CryptoViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("Binance Spot Live")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())

                        Spacer()

                        if let lastUpdated = viewModel.lastUpdated {
                            Text(lastUpdated, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)

                    // Rate badge with animation
                    HStack(spacing: 8) {
                        CryptoIconView(symbol: viewModel.sourceCrypto.symbol, size: 20)
                        Text("1 \(viewModel.sourceCrypto.symbol)")
                            .font(.system(.subheadline, design: .monospaced).bold())

                        Image(systemName: "arrow.right")
                            .font(.caption.bold())
                            .foregroundColor(.blue)

                        Text("\(formatExactNumber(viewModel.exchangeRate, maxDecimals: 6)) \(viewModel.targetCrypto.symbol)")
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(.blue)
                        CryptoIconView(symbol: viewModel.targetCrypto.symbol, size: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())

                    // Source input box
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Вы отдаете")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Menu {
                                ForEach(viewModel.cryptos) { crypto in
                                    Button(action: {
                                        HapticManager.impact(style: .light)
                                        viewModel.sourceCrypto = crypto
                                    }) {
                                        Text("\(crypto.symbol) — \(crypto.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    CryptoIconView(symbol: viewModel.sourceCrypto.symbol, size: 24)
                                    Text(viewModel.sourceCrypto.symbol)
                                        .bold()
                                    Image(systemName: "chevron.down")
                                        .font(.caption2.bold())
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }

                        HStack {
                            TextField("0.0", text: $viewModel.inputAmountText)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif

                            Spacer()

                            Text(viewModel.sourceCrypto.symbol)
                                .font(.title3.bold())
                                .foregroundColor(.secondary)
                        }

                        // Presets
                        HStack(spacing: 8) {
                            ForEach([10, 50, 100, 500, 1000], id: \.self) { amount in
                                Button(action: {
                                    HapticManager.impact(style: .light)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.inputAmountText = "\(amount)"
                                    }
                                }) {
                                    Text("+\(amount)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.cardBackground)
                    )

                    // Swap Button with 180-degree rotation animation
                    Button(action: {
                        HapticManager.impact(style: .medium)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            swapRotation += 180
                            viewModel.swapCurrencies()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 52, height: 52)
                                .shadow(color: Color.blue.opacity(0.35), radius: 8, y: 4)

                            Image(systemName: "arrow.up.arrow.down")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(swapRotation))
                        }
                    }
                    .buttonStyle(.plain)

                    // Target result box
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Вы получаете")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Menu {
                                ForEach(viewModel.cryptos) { crypto in
                                    Button(action: {
                                        HapticManager.impact(style: .light)
                                        viewModel.targetCrypto = crypto
                                    }) {
                                        Text("\(crypto.symbol) — \(crypto.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    CryptoIconView(symbol: viewModel.targetCrypto.symbol, size: 24)
                                    Text(viewModel.targetCrypto.symbol)
                                        .bold()
                                    Image(systemName: "chevron.down")
                                        .font(.caption2.bold())
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }

                        HStack {
                            Text(formatExactNumber(viewModel.convertedAmount, maxDecimals: 6))
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(viewModel.targetCrypto.symbol)
                                .font(.title3.bold())
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("≈ $\(formatExactNumber(viewModel.convertedAmount * viewModel.targetCrypto.priceUSD, maxDecimals: 2)) USD")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("Курс: $\(formatExactNumber(viewModel.sourceCrypto.priceUSD, maxDecimals: 4))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.cardBackground)
                    )

                    // Quick Toggle for TON ⇄ USDT
                    Button(action: {
                        HapticManager.impact(style: .medium)
                        let defaults = viewModel.cryptos
                        if let ton = defaults.first(where: { $0.symbol == "TON" }),
                           let usdt = defaults.first(where: { $0.symbol == "USDT" }) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.sourceCrypto = ton
                                viewModel.targetCrypto = usdt
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            CryptoIconView(symbol: "TON", size: 24)
                            Text("TON ⇄ USDT (Мгновенный обмен)")
                                .font(.subheadline.bold())
                            CryptoIconView(symbol: "USDT", size: 24)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.0, green: 0.5, blue: 1.0), Color(red: 0.0, green: 0.35, blue: 0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.blue.opacity(0.25), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("Конвертер")
        }
    }

    private func formatExactNumber(_ value: Double, maxDecimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxDecimals
        formatter.minimumFractionDigits = (value < 1.0 && value > 0) ? 4 : 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.\(maxDecimals)f", value)
    }
}
