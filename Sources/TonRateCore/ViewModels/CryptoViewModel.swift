import Foundation
import Combine

@MainActor
public final class CryptoViewModel: ObservableObject {
    @Published public var cryptos: [CryptoItem] = CryptoItem.defaults
    @Published public var exchangeTickers: [ExchangeTicker] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var lastUpdated: Date? = nil

    // Converter State
    @Published public var inputAmountText: String = "10"
    @Published public var sourceCrypto: CryptoItem
    @Published public var targetCrypto: CryptoItem

    private let apiService: CryptoAPIServiceProtocol
    private var refreshTimer: AnyCancellable?

    public init(apiService: CryptoAPIServiceProtocol = CryptoAPIService.shared) {
        self.apiService = apiService
        let defaults = CryptoItem.defaults
        let ton = defaults.first(where: { $0.symbol == "TON" }) ?? defaults[0]
        let usdt = defaults.first(where: { $0.symbol == "USDT" }) ?? defaults[1]
        self.sourceCrypto = ton
        self.targetCrypto = usdt

        setupAutoRefresh()
    }

    public func loadData() async {
        isLoading = true
        errorMessage = nil

        async let fetchedCryptos = apiService.fetchCryptoPrices()
        async let fetchedExchanges = apiService.fetchTonExchangeRates()

        do {
            let (newCryptos, newExchanges) = try await (fetchedCryptos, fetchedExchanges)
            self.cryptos = newCryptos
            self.exchangeTickers = newExchanges
            self.lastUpdated = Date()

            // Update source and target references with fresh prices
            if let updatedSource = newCryptos.first(where: { $0.id == sourceCrypto.id }) {
                self.sourceCrypto = updatedSource
            }
            if let updatedTarget = newCryptos.first(where: { $0.id == targetCrypto.id }) {
                self.targetCrypto = updatedTarget
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    public func swapCurrencies() {
        let temp = sourceCrypto
        sourceCrypto = targetCrypto
        targetCrypto = temp
    }

    public var parsedInputAmount: Double {
        let cleaned = inputAmountText.replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0.0
    }

    public var exchangeRate: Double {
        guard targetCrypto.priceUSD > 0 else { return 0 }
        return sourceCrypto.priceUSD / targetCrypto.priceUSD
    }

    public var convertedAmount: Double {
        return parsedInputAmount * exchangeRate
    }

    public var bestBuyExchange: ExchangeTicker? {
        // Best to buy = lowest price
        exchangeTickers.min(by: { $0.price < $1.price })
    }

    public var bestSellExchange: ExchangeTicker? {
        // Best to sell = highest price
        exchangeTickers.max(by: { $0.price < $1.price })
    }

    public var arbitrageSpreadPercent: Double {
        guard let lowest = bestBuyExchange?.price,
              let highest = bestSellExchange?.price,
              lowest > 0 else { return 0 }
        return ((highest - lowest) / lowest) * 100.0
    }

    private func setupAutoRefresh() {
        // Refresh every 30 seconds
        refreshTimer = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.loadData()
                }
            }
    }

    deinit {
        refreshTimer?.cancel()
    }
}
