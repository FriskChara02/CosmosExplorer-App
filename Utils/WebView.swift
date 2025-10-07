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

    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Failed to load: \(error)")
            print("Error details: \(error.localizedDescription)")
            let nsError = error as NSError
            print("Error code: \(nsError.code), domain: \(nsError.domain), userInfo: \(nsError.userInfo)")
            
            if nsError.code == -1005 || nsError.code == -1017 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    guard let originalURL = webView.url, originalURL.absoluteString != "about:blank" else {
                        let fallbackRequest = URLRequest(url: URL(string: "https://www.youtube.com")!)
                        webView.load(fallbackRequest)
                        return
                    }
                    let request = URLRequest(url: originalURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                    webView.load(request)
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Finished loading: \(webView.url?.absoluteString ?? "")")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.suppressesIncrementalRendering = false
        configuration.dataDetectorTypes = []
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.pinchGestureRecognizer?.isEnabled = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 3.0
        webView.allowsLinkPreview = true
        webView.isUserInteractionEnabled = true

        if url.isFileURL || url.scheme == "http" || url.scheme == "https" {
            if url.absoluteString.contains("youtube.com/embed") {
                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                request.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
                webView.load(request)
            } else {
                var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                webView.load(request)
            }
        } else {
            print("Invalid URL: \(url)")
            webView.loadHTMLString("<html><body style='background-color:black;color:white;'><h2>Unable to load content</h2></body></html>", baseURL: nil)
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            if url.isFileURL || url.scheme == "http" || url.scheme == "https" {
                if url.absoluteString.contains("youtube.com/embed") {
                    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                    request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                    request.setValue("https://www.youtube.com", forHTTPHeaderField: "Referer")
                    uiView.load(request)
                } else {
                    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
                    request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
                    uiView.load(request)
                }
            } else {
                print("Invalid URL in updateUIView: \(url)")
                uiView.loadHTMLString("<html><body style='background-color:black;color:white;'><h2>Unable to load content</h2></body></html>", baseURL: nil)
            }
        }
    }
}
