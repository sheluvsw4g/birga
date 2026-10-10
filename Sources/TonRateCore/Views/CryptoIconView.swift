import SwiftUI

public struct CryptoIconView: View {
    public let symbol: String
    public var size: CGFloat = 36

    public init(symbol: String, size: CGFloat = 36) {
        self.symbol = symbol
        self.size = size
    }

    public var body: some View {
        ZStack {
            switch symbol.uppercased() {
            case "TON":
                TonVectorLogo(size: size)
            case "USDT":
                UsdtVectorLogo(size: size)
            case "BTC":
                BtcVectorLogo(size: size)
            case "ETH":
                EthVectorLogo(size: size)
            case "SOL":
                SolVectorLogo(size: size)
            case "NOT":
                NotVectorLogo(size: size)
            default:
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(symbol.prefix(1))
                            .font(.system(size: size * 0.45, weight: .bold))
                            .foregroundColor(.blue)
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - TON Vector Logo
struct TonVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.0, green: 0.53, blue: 0.95), Color(red: 0.0, green: 0.35, blue: 0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Diamond faceted shape
            Image(systemName: "suit.diamond.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.55, height: size * 0.55)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - USDT Vector Logo
struct UsdtVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.16, green: 0.77, blue: 0.59), Color(red: 0.08, green: 0.58, blue: 0.44)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("₮")
                .font(.system(size: size * 0.6, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - BTC Vector Logo
struct BtcVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.97, green: 0.58, blue: 0.1), Color(red: 0.93, green: 0.45, blue: 0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("₿")
                .font(.system(size: size * 0.58, weight: .bold, design: .serif))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ETH Vector Logo
struct EthVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.41, green: 0.45, blue: 0.71), Color(red: 0.28, green: 0.31, blue: 0.56)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Ξ")
                .font(.system(size: size * 0.55, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - SOL Vector Logo
struct SolVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.61, green: 0.22, blue: 0.88), Color(red: 0.12, green: 0.86, blue: 0.69)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: size * 0.08) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white)
                    .frame(width: size * 0.45, height: size * 0.08)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white)
                    .frame(width: size * 0.45, height: size * 0.08)
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white)
                    .frame(width: size * 0.45, height: size * 0.08)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - NOT Vector Logo
struct NotVectorLogo: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.82, blue: 0.15), Color(red: 0.85, green: 0.65, blue: 0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "circle.circle")
                .resizable()
                .frame(width: size * 0.55, height: size * 0.55)
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(width: size, height: size)
    }
}
