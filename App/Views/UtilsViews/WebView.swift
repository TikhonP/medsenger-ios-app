//
//  WebView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import WebKit
import os.log

class WebViewViewModel: ObservableObject {
    @Published var isLoaderVisible: Bool = true
}

struct WebView: UIViewRepresentable {

    var url: URL

    @ObservedObject var viewModel: WebViewViewModel
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WebView.self)
    )

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()

        configuration.preferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        Task {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
        
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ webView: WebView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.viewModel.isLoaderVisible = false
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.parent.viewModel.isLoaderVisible = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            WebView.logger.error("Web View error: didFailProvisionalNavigation: \(error.localizedDescription)")
            self.parent.viewModel.isLoaderVisible = false
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            self.parent.viewModel.isLoaderVisible = true
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            WebView.logger.error("Web View error: didFail: \(error.localizedDescription)")
            self.parent.viewModel.isLoaderVisible = false
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
            decisionHandler(.allow, preferences)
        }

        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {

        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            self.parent.viewModel.isLoaderVisible = false
        }

    }

}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://www.google.com/")!, viewModel: WebViewViewModel())
            .edgesIgnoringSafeArea(.bottom)
    }
}
