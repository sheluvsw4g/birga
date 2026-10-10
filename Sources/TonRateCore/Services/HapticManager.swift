import SwiftUI

#if canImport(UIKit)
import UIKit

public enum HapticManager {
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
        #endif
    }
}
#else
public enum HapticManager {
    public static func impact() {}
    public static func notification() {}
}
#endif
