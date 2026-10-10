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

    // MARK: - CoinGecko Simple Prices
    public func fetchCryptoPrices() async throws -> [CryptoItem] {
        let coinIds = ["the-open-network", "tether", "bitcoin", "ethereum", "solana", "notcoin"]
        let idsParam = coinIds.joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(idsParam)&vs_currencies=usd&include_24hr_change=true"

        guard let url = URL(string: urlString) else {
            throw RateError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return fallbackCryptoItems()
            }

            // [id: ["usd": 5.4, "usd_24h_change": 1.2]]
            let json = try JSONDecoder().decode([String: [String: Double]].self, from: data)

            var items: [CryptoItem] = []
            let meta: [(id: String, symbol: String, name: String, emoji: String)] = [
                ("the-open-network", "TON", "Toncoin", "💎"),
                ("tether", "USDT", "Tether USD", "💵"),
                ("bitcoin", "BTC", "Bitcoin", "₿"),
                ("ethereum", "ETH", "Ethereum", "Ξ"),
                ("solana", "SOL", "Solana", "🟣"),
                ("notcoin", "NOT", "Notcoin", "🪙")
            ]

            for coin in meta {
                let coinData = json[coin.id] ?? [:]
                let price = coinData["usd"] ?? (coin.symbol == "USDT" ? 1.0 : 0.0)
                let change = coinData["usd_24h_change"] ?? 0.0

                items.append(
                    CryptoItem(
                        id: coin.id,
                        symbol: coin.symbol,
                        name: coin.name,
                        emoji: coin.emoji,
                        priceUSD: price,
                        change24h: change
                    )
                )
            }
            return items
        } catch {
            return fallbackCryptoItems()
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

    // MARK: - Binance
    private func fetchBinanceTonRate() async -> ExchangeTicker? {
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/24hr?symbol=TONUSDT") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 6

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }

            struct BinanceResponse: Decodable {
                let lastPrice: String
                let priceChangePercent: String
                let highPrice: String
                let lowPrice: String
                let quoteVolume: String
            }

            let decoded = try JSONDecoder().decode(BinanceResponse.self, from: data)
            guard let price = Double(decoded.lastPrice),
                  let change = Double(decoded.priceChangePercent) else { return nil }

            return ExchangeTicker(
                exchange: "Binance",
                pair: "TON / USDT",
                price: price,
                change24h: change,
                high24h: Double(decoded.highPrice) ?? 0,
                low24h: Double(decoded.lowPrice) ?? 0,
                volumeUSD: Double(decoded.quoteVolume) ?? 0
            )
        } catch {
            return nil
        }
    }

    // MARK: - Bybit
    private func fetchBybitTonRate() async -> ExchangeTicker? {
        guard let url = URL(string: "https://api.bybit.com/v5/market/tickers?category=spot&symbol=TONUSDT") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 6

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

            let change = rawChange * 100 // Bybit returns decimal (e.g. 0.024)

            return ExchangeTicker(
                exchange: "Bybit",
                pair: "TON / USDT",
                price: price,
                change24h: change,
                high24h: Double(first.highPrice24h) ?? 0,
                low24h: Double(first.lowPrice24h) ?? 0,
                volumeUSD: Double(first.turnover24h) ?? 0
            )
        } catch {
            return nil
        }
    }

    // MARK: - OKX
    private func fetchOkxTonRate() async -> ExchangeTicker? {
        guard let url = URL(string: "https://www.okx.com/api/v5/market/ticker?instId=TON-USDT") else { return nil }
        var request = URLRequest(url: url)
        request.timeoutInterval = 6

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

            let change = ((price - open) / open) * 100

            return ExchangeTicker(
                exchange: "OKX",
                pair: "TON / USDT",
                price: price,
                change24h: change,
                high24h: Double(first.high24h) ?? 0,
                low24h: Double(first.low24h) ?? 0,
                volumeUSD: Double(first.volCcy24h) ?? 0
            )
        } catch {
            return nil
        }
    }

    // MARK: - Fallback Data
    public func fallbackCryptoItems() -> [CryptoItem] {
        return CryptoItem.defaults
    }

    public func fallbackExchangeTickers() -> [ExchangeTicker] {
        return [
            ExchangeTicker(exchange: "Binance", pair: "TON / USDT", price: 5.432, change24h: 2.14, high24h: 5.55, low24h: 5.28, volumeUSD: 48_250_000),
            ExchangeTicker(exchange: "Bybit", pair: "TON / USDT", price: 5.428, change24h: 2.05, high24h: 5.54, low24h: 5.27, volumeUSD: 31_120_000),
            ExchangeTicker(exchange: "OKX", pair: "TON / USDT", price: 5.435, change24h: 2.21, high24h: 5.56, low24h: 5.29, volumeUSD: 24_890_000)
        ]
    }
}
