import SwiftUI

public struct ConverterView: View {
    @ObservedObject public var viewModel: CryptoViewModel

    public init(viewModel: CryptoViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(spacing: 8) {
                        Text("Конвертер TON & Crypto")
                            .font(.title2.bold())
                        Text("Мгновенный расчет курсов по реальным рыночным ценам")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)

                    // Rate badge
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.swap")
                            .foregroundColor(.blue)
                        Text("1 \(viewModel.sourceCrypto.symbol) ≈ \(formatNumber(viewModel.exchangeRate, decimals: 4)) \(viewModel.targetCrypto.symbol)")
                            .font(.system(.subheadline, design: .monospaced).bold())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Capsule())

                    // Source input box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Вы отдаете")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Menu {
                                ForEach(viewModel.cryptos) { crypto in
                                    Button(action: { viewModel.sourceCrypto = crypto }) {
                                        Text("\(crypto.emoji) \(crypto.symbol) - \(crypto.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.sourceCrypto.emoji)
                                    Text(viewModel.sourceCrypto.symbol)
                                        .bold()
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }

                        HStack {
                            TextField("0.0", text: $viewModel.inputAmountText)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
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
                            ForEach([10, 50, 100, 500], id: \.self) { amount in
                                Button(action: {
                                    viewModel.inputAmountText = "\(amount)"
                                }) {
                                    Text("+\(amount)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
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
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.cardBackground)
                    )

                    // Swap Button
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.swapCurrencies()
                        }
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)

                    // Target result box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Вы получаете")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Menu {
                                ForEach(viewModel.cryptos) { crypto in
                                    Button(action: { viewModel.targetCrypto = crypto }) {
                                        Text("\(crypto.emoji) \(crypto.symbol) - \(crypto.name)")
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.targetCrypto.emoji)
                                    Text(viewModel.targetCrypto.symbol)
                                        .bold()
                                    Image(systemName: "chevron.down")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }

                        HStack {
                            Text(formatNumber(viewModel.convertedAmount, decimals: 4))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Spacer()

                            Text(viewModel.targetCrypto.symbol)
                                .font(.title3.bold())
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("Ориентировочная стоимость: $\(formatNumber(viewModel.convertedAmount * viewModel.targetCrypto.priceUSD, decimals: 2))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.cardBackground)
                    )

                    // Quick Toggle for TON <-> USDT
                    Button(action: {
                        let defaults = viewModel.cryptos
                        if let ton = defaults.first(where: { $0.symbol == "TON" }),
                           let usdt = defaults.first(where: { $0.symbol == "USDT" }) {
                            withAnimation {
                                viewModel.sourceCrypto = ton
                                viewModel.targetCrypto = usdt
                            }
                        }
                    }) {
                        HStack {
                            Text("💎 TON ⇄ 💵 USDT (Прямой обмен)")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("Конвертер")
        }
    }

    private func formatNumber(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
