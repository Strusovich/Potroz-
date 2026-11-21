import SwiftUI

/// The three destinations exposed by the native Liquid Glass tab bar.
enum AppTab: String, CaseIterable, Identifiable {
    case chats
    case anime
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chats: return "Чаты"
        case .anime: return "Аниме"
        case .settings: return "Настройки"
        }
    }

    var symbol: String {
        switch self {
        case .chats: return "bubble.left.and.bubble.right.fill"
        case .anime: return "sparkles"
        case .settings: return "slider.horizontal.3"
        }
    }

    var webURL: URL? {
        switch self {
        case .chats:
            return URL(string: "https://web.telegram.org/k/")
        case .anime:
            return URL(string: "https://web.telegram.org/k/#@qanimebot")
        case .settings:
            return nil
        }
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
