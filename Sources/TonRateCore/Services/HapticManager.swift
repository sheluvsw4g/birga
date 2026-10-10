import Foundation

#if os(iOS)
import UIKit

public enum HapticFeedbackStyle {
    case light, medium, heavy
}

public enum HapticFeedbackType {
    case success, warning, error
}

public enum HapticManager {
    public static func impact(style: HapticFeedbackStyle = .medium) {
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        }
        let generator = UIImpactFeedbackGenerator(style: uiStyle)
        generator.prepare()
        generator.impactOccurred()
    }

    public static func notification(type: HapticFeedbackType = .success) {
        let uiType: UINotificationFeedbackGenerator.FeedbackType
        switch type {
        case .success: uiType = .success
        case .warning: uiType = .warning
        case .error: uiType = .error
        }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(uiType)
    }
}
#else
public enum HapticFeedbackStyle {
    case light, medium, heavy
}

public enum HapticFeedbackType {
    case success, warning, error
}

public enum HapticManager {
    public static func impact(style: HapticFeedbackStyle = .medium) {}
    public static func notification(type: HapticFeedbackType = .success) {}
}
#endif
