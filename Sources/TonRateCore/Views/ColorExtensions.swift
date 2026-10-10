import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public static var cardBackground: Color {
        #if os(iOS)
        return Color(uiColor: .secondarySystemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }

    public static var subtleBackground: Color {
        #if os(iOS)
        return Color(uiColor: .tertiarySystemBackground)
        #elseif os(macOS)
        return Color(nsColor: .underPageBackgroundColor)
        #else
        return Color.gray.opacity(0.08)
        #endif
    }
}
