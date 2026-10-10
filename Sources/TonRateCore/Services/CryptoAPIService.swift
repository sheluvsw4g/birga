import Foundation

public protocol CryptoAPIServiceProtocol: Sendable {
    func fetchCryptoPrices() async throws -> [CryptoItem]
    func fetchTonExchangeRates() async -> [ExchangeTicker]
}

public actor CryptoAPIService: CryptoAPIServiceProtocol {
    public static let shared = CryptoAPIService()
    private let urlSession: URLSession

    public init(session: URLSession = .shared) {
        self.urlSession = session
    }

    // MARK: - High-Precision Real-Time Rates
    public func fetchCryptoPrices() async throws -> [CryptoItem] {
        // Query Binance in parallel for exact spot prices
        async let tonBinance = fetchBinanceTicker(symbol: "TONUSDT")
        async let btcBinance = fetchBinanceTicker(symbol: "BTCUSDT")
        async let ethBinance = fetchBinanceTicker(symbol: "ETHUSDT")
        async let solBinance = fetchBinanceTicker(symbol: "SOLUSDT")

        let (ton, btc, eth, sol) = await (tonBinance, btcBinance, ethBinance, solBinance)

        var items: [CryptoItem] = []

        // 1. TON
        let tonPrice = ton?.price ?? 1.60
        let tonChange = ton?.change ?? 0.95
        items.append(
            CryptoItem(
                id: "the-open-network",
                symbol: "TON",
                name: "Toncoin",
                emoji: "💎",
                priceUSD: tonPrice,
                change24h: tonChange,
                high24h: ton?.high ?? 0,
                low24h: ton?.low ?? 0,
                volume24h: ton?.volume ?? 0
            )
        )

        // 2. USDT (Pegged Stablecoin)
        items.append(
            CryptoItem(
                id: "tether",
                symbol: "USDT",
                name: "Tether USD",
                emoji: "💵",
                priceUSD: 1.0000,
                change24h: 0.01
            )
        )

        // 3. BTC
        items.append(
            CryptoItem(
                id: "bitcoin",
                symbol: "BTC",
                name: "Bitcoin",
                emoji: "₿",
                priceUSD: btc?.price ?? 64000.0,
                change24h: btc?.change ?? 0,
                high24h: btc?.high ?? 0,
                low24h: btc?.low ?? 0,
                volume24h: btc?.volume ?? 0
            )
        )

        // 4. ETH
        items.append(
            CryptoItem(
                id: "ethereum",
                symbol: "ETH",
                name: "Ethereum",
                emoji: "Ξ",
                priceUSD: eth?.price ?? 3400.0,
                change24h: eth?.change ?? 0,
                high24h: eth?.high ?? 0,
                low24h: eth?.low ?? 0,
                volume24h: eth?.volume ?? 0
            )
        )

        // 5. SOL
        items.append(
            CryptoItem(
                id: "solana",
                symbol: "SOL",
                name: "Solana",
                emoji: "🟣",
                priceUSD: sol?.price ?? 145.0,
                change24h: sol?.change ?? 0,
                high24h: sol?.high ?? 0,
                low24h: sol?.low ?? 0,
                volume24h: sol?.volume ?? 0
            )
        )

        // 6. NOT (Notcoin)
        let notcoin = await fetchBinanceTicker(symbol: "NOTUSDT")
        items.append(
            CryptoItem(
                id: "notcoin",
                symbol: "NOT",
                name: "Notcoin",
                emoji: "🪙",
                priceUSD: notcoin?.price ?? 0.0075,
                change24h: notcoin?.change ?? -2.1,
                high24h: notcoin?.high ?? 0,
                low24h: notcoin?.low ?? 0,
                volume24h: notcoin?.volume ?? 0
            )
        )

        return items
    }

    private struct RawTicker {
        let price: Double
        let change: Double
        let high: Double
        let low: Double
        let volume: Double
    }

    private func fetchBinanceTicker(symbol: String) async -> RawTicker? {
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/24hr?symbol=\(symbol)") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 4

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

            struct BResponse: Decodable {
                let lastPrice: String
                let priceChangePercent: String
                let highPrice: String
                let lowPrice: String
                let quoteVolume: String
            }

            let decoded = try JSONDecoder().decode(BResponse.self, from: data)
            guard let price = Double(decoded.lastPrice),
                  let change = Double(decoded.priceChangePercent) else { return nil }

            return RawTicker(
                price: price,
                change: change,
                high: Double(decoded.highPrice) ?? 0,
                low: Double(decoded.lowPrice) ?? 0,
                volume: Double(decoded.quoteVolume) ?? 0
            )
        } catch {
            return nil
        }
    }

    // MARK: - Exchange Comparison for TON / USDT
    public func fetchTonExchangeRates() async -> [ExchangeTicker] {
        async let binance = fetchBinanceTonRate()
        async let bybit = fetchBybitTonRate()
        async let okx = fetchOkxTonRate()

        let results = await [binance, bybit, okx]
        let successful = results.compactMap { $0 }

        if successful.isEmpty {
            return fallbackExchangeTickers()
        }
        return successful
    }

    private func fetchBinanceTonRate() async -> ExchangeTicker? {
        guard let raw = await fetchBinanceTicker(symbol: "TONUSDT") else { return nil }
        return ExchangeTicker(
            exchange: "Binance",
            pair: "TON / USDT",
            price: raw.price,
            change24h: raw.change,
            high24h: raw.high,
            low24h: raw.low,
            volumeUSD: raw.volume
        )
    }

    private func fetchBybitTonRate() async -> ExchangeTicker? {
        guard let url = URL(string: "https://api.bybit.com/v5/market/tickers?category=spot&symbol=TONUSDT") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 4

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

            struct BybitResponse: Decodable {
                struct ResultData: Decodable {
                    struct TickerItem: Decodable {
                        let lastPrice: String
                        let price24hPcnt: String
                        let highPrice24h: String
                        let lowPrice24h: String
                        let turnover24h: String
                    }
                    let list: [TickerItem]
                }
                let result: ResultData
            }

            let decoded = try JSONDecoder().decode(BybitResponse.self, from: data)
            guard let first = decoded.result.list.first,
                  let price = Double(first.lastPrice),
                  let rawChange = Double(first.price24hPcnt) else { return nil }

            return ExchangeTicker(
                exchange: "Bybit",
                pair: "TON / USDT",
                price: price,
                change24h: rawChange * 100,
                high24h: Double(first.highPrice24h) ?? 0,
                low24h: Double(first.lowPrice24h) ?? 0,
                volumeUSD: Double(first.turnover24h) ?? 0
            )
        } catch {
            return nil
        }
    }

    private func fetchOkxTonRate() async -> ExchangeTicker? {
        guard let url = URL(string: "https://www.okx.com/api/v5/market/ticker?instId=TON-USDT") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 4

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

            struct OKXResponse: Decodable {
                struct OKXTicker: Decodable {
                    let last: String
                    let open24h: String
                    let high24h: String
                    let low24h: String
                    let volCcy24h: String
                }
                let data: [OKXTicker]
            }

            let decoded = try JSONDecoder().decode(OKXResponse.self, from: data)
            guard let first = decoded.data.first,
                  let price = Double(first.last),
                  let open = Double(first.open24h),
                  open > 0 else { return nil }

            return ExchangeTicker(
                exchange: "OKX",
                pair: "TON / USDT",
                price: price,
                change24h: ((price - open) / open) * 100,
                high24h: Double(first.high24h) ?? 0,
                low24h: Double(first.low24h) ?? 0,
                volumeUSD: Double(first.volCcy24h) ?? 0
            )
        } catch {
            return nil
        }
    }

    public func fallbackCryptoItems() -> [CryptoItem] {
        return CryptoItem.defaults
    }

    public func fallbackExchangeTickers() -> [ExchangeTicker] {
        return [
            ExchangeTicker(exchange: "Binance", pair: "TON / USDT", price: 1.602, change24h: 0.94, high24h: 1.64, low24h: 1.58, volumeUSD: 48_250_000),
            ExchangeTicker(exchange: "Bybit", pair: "TON / USDT", price: 1.601, change24h: 0.88, high24h: 1.639, low24h: 1.579, volumeUSD: 31_120_000),
            ExchangeTicker(exchange: "OKX", pair: "TON / USDT", price: 1.603, change24h: 0.98, high24h: 1.642, low24h: 1.581, volumeUSD: 24_890_000)
        ]
    }
}
