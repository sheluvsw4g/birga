import Foundation

public struct CryptoItem: Identifiable, Hashable, Codable {
    public let id: String
    public let symbol: String
    public let name: String
    public let emoji: String
    public var priceUSD: Double
    public var change24h: Double
    public var high24h: Double
    public var low24h: Double
    public var volume24h: Double

    public init(
        id: String,
        symbol: String,
        name: String,
        emoji: String,
        priceUSD: Double,
        change24h: Double = 0.0,
        high24h: Double = 0.0,
        low24h: Double = 0.0,
        volume24h: Double = 0.0
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.emoji = emoji
        self.priceUSD = priceUSD
        self.change24h = change24h
        self.high24h = high24h
        self.low24h = low24h
        self.volume24h = volume24h
    }

    public static let defaults: [CryptoItem] = [
        CryptoItem(id: "the-open-network", symbol: "TON", name: "Toncoin", emoji: "💎", priceUSD: 5.42, change24h: 2.35),
        CryptoItem(id: "tether", symbol: "USDT", name: "Tether USD", emoji: "💵", priceUSD: 1.00, change24h: 0.01),
        CryptoItem(id: "bitcoin", symbol: "BTC", name: "Bitcoin", emoji: "₿", priceUSD: 64200.0, change24h: -1.2),
        CryptoItem(id: "ethereum", symbol: "ETH", name: "Ethereum", emoji: "Ξ", priceUSD: 3450.0, change24h: 0.8),
        CryptoItem(id: "solana", symbol: "SOL", name: "Solana", emoji: "🟣", priceUSD: 148.5, change24h: 4.1),
        CryptoItem(id: "notcoin", symbol: "NOT", name: "Notcoin", emoji: "🪙", priceUSD: 0.0078, change24h: -3.4)
    ]
}

public struct ExchangeTicker: Identifiable, Hashable, Codable {
    public var id: String { "\(exchange)_\(pair)" }
    public let exchange: String
    public let pair: String
    public let price: Double
    public let change24h: Double
    public let high24h: Double
    public let low24h: Double
    public let volumeUSD: Double
    public let timestamp: Date

    public init(
        exchange: String,
        pair: String,
        price: Double,
        change24h: Double,
        high24h: Double = 0,
        low24h: Double = 0,
        volumeUSD: Double = 0,
        timestamp: Date = Date()
    ) {
        self.exchange = exchange
        self.pair = pair
        self.price = price
        self.change24h = change24h
        self.high24h = high24h
        self.low24h = low24h
        self.volumeUSD = volumeUSD
        self.timestamp = timestamp
    }
}

public enum RateError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case decodingError
    case dataUnavailable

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL-адрес запроса."
        case .networkError(let message):
            return "Сетевая ошибка: \(message)"
        case .decodingError:
            return "Ошибка обработки ответа API."
        case .dataUnavailable:
            return "Данные о курсах временно недоступны."
        }
    }
}
