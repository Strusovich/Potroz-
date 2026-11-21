import SwiftUI
import WebKit

struct TelegramWebView: UIViewRepresentable {
    @ObservedObject var session: TelegramWebSession

    func makeUIView(context: Context) -> WKWebView {
        session.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Navigation is controlled by TelegramWebSession so the WKWebView and its login
        // cookies survive tab changes.
    }
}
