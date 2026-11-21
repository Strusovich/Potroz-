import Foundation
import Combine
import WebKit
import UIKit

@MainActor
final class TelegramWebSession: NSObject, ObservableObject {
    @Published private(set) var isLoading = true
    @Published private(set) var loadError: String?

    let webView: WKWebView

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.isInspectable = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.backgroundColor = .systemBackground
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        if let url = AppTab.chats.webURL {
            webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45))
        }
    }

    func show(_ tab: AppTab) {
        guard let url = tab.webURL else { return }
        loadError = nil
        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 45))
    }

    func reload() {
        loadError = nil
        webView.reload()
    }

    @objc private func refreshPage() {
        webView.reload()
    }

    private func openExternalScheme(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension TelegramWebSession: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        loadError = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        loadError = nil
        webView.scrollView.refreshControl?.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finishWith(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finishWith(error: error)
    }

    private func finishWith(error: Error) {
        isLoading = false
        webView.scrollView.refreshControl?.endRefreshing()
        let nsError = error as NSError
        guard nsError.code != NSURLErrorCancelled else { return }
        loadError = "Не удалось загрузить Telegram Web. Проверь подключение и попробуй ещё раз."
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased() else {
            decisionHandler(.allow)
            return
        }

        let webSchemes: Set<String> = ["https", "http", "about", "blob", "data", "javascript"]
        if webSchemes.contains(scheme) {
            decisionHandler(.allow)
        } else {
            openExternalScheme(url)
            decisionHandler(.cancel)
        }
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Telegram Web occasionally opens links with target="_blank".
        // Keep those links in the same authenticated web session.
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void
    ) {
        // Let iOS show its normal permission prompt when a site requests camera or microphone access.
        decisionHandler(.prompt)
    }
}
