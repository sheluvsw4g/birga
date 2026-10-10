import XCTest
@testable import TonRateCore

final class TonRateCoreTests: XCTestCase {

    @MainActor
    func testConversionCalculation() async {
        let viewModel = CryptoViewModel()
        let ton = CryptoItem(id: "ton", symbol: "TON", name: "Toncoin", emoji: "💎", priceUSD: 5.0)
        let usdt = CryptoItem(id: "usdt", symbol: "USDT", name: "Tether", emoji: "💵", priceUSD: 1.0)

        viewModel.sourceCrypto = ton
        viewModel.targetCrypto = usdt
        viewModel.inputAmountText = "20"

        XCTAssertEqual(viewModel.parsedInputAmount, 20.0)
        XCTAssertEqual(viewModel.exchangeRate, 5.0)
        XCTAssertEqual(viewModel.convertedAmount, 100.0)
    }

    @MainActor
    func testReverseConversionCalculation() async {
        let viewModel = CryptoViewModel()
        let ton = CryptoItem(id: "ton", symbol: "TON", name: "Toncoin", emoji: "💎", priceUSD: 5.0)
        let usdt = CryptoItem(id: "usdt", symbol: "USDT", name: "Tether", emoji: "💵", priceUSD: 1.0)

        viewModel.sourceCrypto = usdt
        viewModel.targetCrypto = ton
        viewModel.inputAmountText = "100"

        XCTAssertEqual(viewModel.parsedInputAmount, 100.0)
        XCTAssertEqual(viewModel.exchangeRate, 0.2)
        XCTAssertEqual(viewModel.convertedAmount, 20.0)
    }

    @MainActor
    func testSwapCurrencies() async {
        let viewModel = CryptoViewModel()
        let ton = CryptoItem(id: "ton", symbol: "TON", name: "Toncoin", emoji: "💎", priceUSD: 5.0)
        let usdt = CryptoItem(id: "usdt", symbol: "USDT", name: "Tether", emoji: "💵", priceUSD: 1.0)

        viewModel.sourceCrypto = ton
        viewModel.targetCrypto = usdt

        viewModel.swapCurrencies()

        XCTAssertEqual(viewModel.sourceCrypto.symbol, "USDT")
        XCTAssertEqual(viewModel.targetCrypto.symbol, "TON")
    }

    @MainActor
    func testArbitrageAndSpread() async {
        let viewModel = CryptoViewModel()
        viewModel.exchangeTickers = [
            ExchangeTicker(exchange: "Binance", pair: "TON/USDT", price: 5.0, change24h: 1.0),
            ExchangeTicker(exchange: "Bybit", pair: "TON/USDT", price: 5.2, change24h: 2.0),
            ExchangeTicker(exchange: "OKX", pair: "TON/USDT", price: 5.1, change24h: 1.5)
        ]

        XCTAssertEqual(viewModel.bestBuyExchange?.exchange, "Binance")
        XCTAssertEqual(viewModel.bestSellExchange?.exchange, "Bybit")

        // Spread: ((5.2 - 5.0) / 5.0) * 100 = 4.0%
        XCTAssertEqual(viewModel.arbitrageSpreadPercent, 4.0, accuracy: 0.001)
    }

    func testFallbackData() async {
        let service = CryptoAPIService()
        let items = await service.fallbackCryptoItems()
        let tickers = await service.fallbackExchangeTickers()

        XCTAssertFalse(items.isEmpty)
        XCTAssertFalse(tickers.isEmpty)
        XCTAssertTrue(items.contains(where: { $0.symbol == "TON" }))
        XCTAssertTrue(tickers.contains(where: { $0.exchange == "Binance" }))
    }
}
