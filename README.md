# 💎 TonRateTracker (Swift & SwiftUI)

Современное мультиплатформенное приложение на **Swift & SwiftUI** для отслеживания курсов **TON (Toncoin)**, **USDT**, **Bitcoin**, **Ethereum**, **Solana**, а также сравнения спреда и цен на крупнейших криптобиржах (**Binance**, **Bybit**, **OKX**).

Проект подготовлен для автоматической сборки и тестирования в облаке через **GitHub Actions** на macOS runners.

---

## 🚀 Основные возможности

1. **Двусторонний конвертер TON ⇄ USDT (и другие монеты)**:
   - Мгновенный расчет обмена по рыночным котировкам.
   - Быстрый свап валют одной кнопкой.
   - Пресеты сумм (+10, +50, +100, +500).
   - Точный расчет до 4-х знаков после запятой.
2. **Сравнение цен на криптобиржах (Arbitrage & Spread)**:
   - Прямой запрос стаканов TON/USDT с Binance, Bybit и OKX.
   - Автоматическое выявление лучшей биржи для покупки (самая низкая цена) и продажи (самая высокая цена).
   - Расчет процента спреда (арбитражная дельта).
   - Отображение суточных минимумов, максимумов и объемов торгов (24h Volume).
3. **Рыночные котировки популярных криптовалют**:
   - TON, USDT, BTC, ETH, SOL, NOT.
   - Изменение цены за 24 часа с цветовой индикацией.
   - Поиск по названию и тикеру.
4. **Асинхронный сетевой слой (Modern Swift Concurrency)**:
   - `async/await` и `actor` для безопасной работы с API без гонок потоков.
   - Автоматическое фоновое обновление каждые 30 секунд.
   - Встроенный fallback-механизм для стабильной работы даже при ограничениях сети.
5. **Мультиплатформенность**:
   - Поддержка iOS 16+ и macOS 13+.

---

## 🛠 Архитектура проекта

```text
TonRateTracker/
├── .github/
│   └── workflows/
│       └── build.yml               # GitHub Actions CI/CD пайплайн
├── Sources/
│   ├── TonRateCore/                # Библиотека логики и UI
│   │   ├── Models/
│   │   │   └── CryptoModels.swift  # Структуры CryptoItem, ExchangeTicker
│   │   ├── Services/
│   │   │   └── CryptoAPIService.swift # Запросы к CoinGecko, Binance, Bybit, OKX
│   │   ├── ViewModels/
│   │   │   └── CryptoViewModel.swift  # Бизнес-логика, конвертер и таймеры
│   │   └── Views/
│   │       ├── ColorExtensions.swift  # Кроссплатформенные цвета iOS/macOS
│   │       ├── ConverterView.swift    # Экран конвертера
│   │       ├── MarketRatesView.swift  # Экран котировок
│   │       ├── ExchangeCompareView.swift # Экран сравнения бирж
│   │       └── MainTabView.swift      # Основной таб-бар
│   └── TonRateTrackerApp/
│       └── TonRateTrackerApp.swift    # @main точка входа SwiftUI
├── Tests/
│   └── TonRateCoreTests/
│       └── TonRateCoreTests.swift     # XCTest юнит-тесты
└── Package.swift                      # Swift Package Manager манифест
```

---

## 🤖 Сборка через GitHub Actions

В репозитории уже настроен пайплайн `.github/workflows/build.yml`.

### Что делает GitHub Actions:
1. Запускается на виртуальной машине **macOS-14 (Apple Silicon)** с установленным Xcode и Swift 5.9+.
2. Разрешает зависимости пакетов (`swift package resolve`).
3. Запускает юнит-тесты (`swift test -v`).
4. Компилирует релизный бинарник (`swift build -c release`).
5. Упаковывает скомпилированное приложение в ZIP-архив и загружает его в раздел **Artifacts** сборки.

### Как запустить:
1. Создай новый репозиторий на GitHub (например, `TonRateTracker`).
2. В терминале в папке проекта инициализируй git и отправь код:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: TON Crypto Tracker on SwiftUI"
   git branch -M main
   git remote add origin https://github.com/<твой_логин>/<имя_репозитория>.git
   git push -u origin main
   ```
3. Открой вкладку **Actions** в своем GitHub-репозитории.
4. Дождись завершения сборки и скачай готовый архив `TonRateTracker-macOS.zip` из секции **Artifacts**!
