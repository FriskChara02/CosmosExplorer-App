//
//  WebView.swift
//  CosmosExplorer
//
//  Created by Loi Nguyen on 6/10/25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var loadedURL: URL?
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Finished loading: \(webView.url?.absoluteString ?? "unknown")")
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        
        webView.isUserInteractionEnabled = true
        webView.scrollView.isUserInteractionEnabled = true
        webView.allowsBackForwardNavigationGestures = false
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        loadContent(in: webView, url: url, coordinator: context.coordinator)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if context.coordinator.loadedURL?.absoluteString != url.absoluteString {
            WKWebsiteDataStore.default().removeData(
                ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                modifiedSince: Date(timeIntervalSince1970: 0),
                completionHandler: {
                    self.loadContent(in: uiView, url: self.url, coordinator: context.coordinator)
                }
            )
        }
    }
    
    private func loadContent(in webView: WKWebView, url: URL, coordinator: Coordinator) {
        coordinator.loadedURL = url
        
        if url.absoluteString.contains("youtube.com") || url.absoluteString.contains("youtu.be") {
            let videoID = extractYouTubeID(from: url.absoluteString)
            
            let timestamp = Int(Date().timeIntervalSince1970)
            
            let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                <meta name="referrer" content="strict-origin-when-cross-origin">
                <style>
                    * { margin:0; padding:0; }
                    html, body { height:100%; background:#000; overflow:hidden; }
                    iframe { position:absolute; top:0; left:0; width:100%; height:100%; border:none; }
                </style>
            </head>
            <body>
                <iframe src="https://www.youtube.com/embed/\(videoID)?playsinline=0&fs=1&rel=0&modestbranding=1&controls=1&t=\(timestamp)"
                        allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
                        allowfullscreen
                        referrerpolicy="strict-origin-when-cross-origin">
                </iframe>
            </body>
            </html>
            """
            
            let fakeBaseURL = URL(string: "https://\(Bundle.main.bundleIdentifier!.replacingOccurrences(of: ".", with: "-")).app")!
            
            webView.loadHTMLString(htmlString, baseURL: fakeBaseURL)
            return
        }
        
        if url.absoluteString.contains("wikipedia.org") {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            webView.load(request)
            return
        }
        
        if url.isFileURL || url.scheme == "http" || url.scheme == "https" {
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            webView.load(request)
        } else {
            print("Invalid URL: \(url)")
            webView.loadHTMLString("<html><body style='background:#000;color:#fff;display:flex;align-items:center;justify-content:center;height:100vh;font-family:system-ui;'><h2>Unable to load content</h2></body></html>", baseURL: nil)
        }
    }
    
    private func extractYouTubeID(from urlString: String) -> String {
        if urlString.contains("embed") {
            return URL(string: urlString)?.lastPathComponent ?? ""
        }
        if urlString.contains("youtu.be") {
            return URL(string: urlString)?.lastPathComponent ?? ""
        }
        if let queryItems = URLComponents(string: urlString)?.queryItems {
            return queryItems.first(where: { $0.name == "v" })?.value ?? ""
        }
        return ""
    }
}
