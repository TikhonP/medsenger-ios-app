//
//  WebView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import WebKit

@available(iOS 13.0, *)
public struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.content()
                    .disabled(self.isShowing)

                ProgressView()
            }
        }
    }

}

public enum WebViewData {
    case url(URL)
    case request(URLRequest)
    case html(String, URL?)
}

@available(iOS 13.0, *)
struct WebViewWrapper : UIViewRepresentable {
    
    @ObservedObject var webViewStateModel: WebViewStateModel
    let action: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?
    
    let webViewData: WebViewData
    let title: String?
    
    let allowedHosts: [String]?
    let forbiddenHosts: [String]?
    let credential: URLCredential?
    
    init(
        webViewStateModel: WebViewStateModel,
        webViewData: WebViewData,
        title: String?,
        action: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?,
        allowedHosts: [String]?,
        forbiddenHosts: [String]?,
        credential: URLCredential?
    ) {
        self.action = action
        self.webViewData = webViewData
        self.title = title
        self.webViewStateModel = webViewStateModel
        self.allowedHosts = allowedHosts
        self.forbiddenHosts = forbiddenHosts
        self.credential = credential
    }
    
    public func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        
        switch webViewData {
        case .url(let url):
            view.load(URLRequest(url: url))
        case .request(let request):
            view.load(request)
        case .html(let html, let url):
            view.loadHTMLString(html, baseURL: url)
        }
        
        return view
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.canGoBack, webViewStateModel.goBack {
            uiView.goBack()
            webViewStateModel.goBack = false
        } else if uiView.canGoForward, webViewStateModel.goForward {
            uiView.goForward()
            webViewStateModel.goForward = false
        } else if webViewStateModel.reload {
            uiView.reload()
            webViewStateModel.reload = false
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            action: action,
            webViewStateModel: webViewStateModel,
            title: title,
            allowedHosts: allowedHosts,
            forbiddenHosts: forbiddenHosts,
            credential: credential
        )
    }
    
    final public class Coordinator: NSObject {
        @ObservedObject var webViewStateModel: WebViewStateModel
        let title: String?
        let action: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?
        let allowedHosts: [String]?
        let forbiddenHosts: [String]?
        let credential: URLCredential?
        
        init(
            action: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?,
            webViewStateModel: WebViewStateModel,
            title: String?,
            allowedHosts: [String]?,
            forbiddenHosts: [String]?,
            credential: URLCredential?
        ) {
            self.action = action
            let modifiedWebViewStateModel = webViewStateModel
            DispatchQueue.main.async {
                modifiedWebViewStateModel.pageTitle = title ?? "Loading..."
            }
            self.webViewStateModel = modifiedWebViewStateModel
            self.title = title
            self.allowedHosts = allowedHosts
            self.forbiddenHosts = forbiddenHosts
            self.credential = credential
        }
        
    }
}

@available(iOS 13.0, *)
extension WebViewWrapper.Coordinator: WKNavigationDelegate {
    
    public func handleAllowedHosts(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let allowedHosts = allowedHosts {
            
            if let host = navigationAction.request.url?.host {
                
                var allowed = false
                allowedHosts.forEach { (allowedHost) in
                    if host.contains(allowedHost) {
                        print("WebView -> Found allowed host: \(allowedHost)")
                        allowed = true
                    }
                }
                
                if allowed {
                    decisionHandler(.allow)
                    action?(.decidePolicy(webView, navigationAction, .allow))
                } else {
                    print("WebView -> Did not find allowed hosts for: \(host)")
                    decisionHandler(.cancel)
                    action?(.decidePolicy(webView, navigationAction, .cancel))
                }
            }
            
        } else {
            print("WebView -> No allowed host are set")
            decisionHandler(.allow)
            action?(.decidePolicy(webView, navigationAction, .allow))
        }
    }
    
    public func handleForbiddenHosts(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    )  {
        if let forbiddenHosts = forbiddenHosts {
            
            if let host = navigationAction.request.url?.host {
                
                var forbidden = false
                forbiddenHosts.forEach { (forbiddenHost) in
                    if host.contains(forbiddenHost) {
                        print("WebView -> Found forbidden host: \(forbiddenHost)")
                        forbidden = true
                    }
                }
                
                if forbidden {
                    decisionHandler(.cancel)
                    action?(.decidePolicy(webView, navigationAction, .cancel))
                } else {
                    print("WebView -> Did not find forbidden hosts for: \(host)")
                    handleAllowedHosts(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
                }
                
            } else {
                decisionHandler(.cancel)
                action?(.decidePolicy(webView, navigationAction, .cancel))
            }
            
        } else {
            print("WebView -> No forbidden host are set")
            handleAllowedHosts(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        }
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        handleForbiddenHosts(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }
    
    public func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        
        if let credential = credential {
            let authenticationMethod = challenge.protectionSpace.authenticationMethod
            if authenticationMethod == NSURLAuthenticationMethodDefault || authenticationMethod == NSURLAuthenticationMethodHTTPBasic || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
                completionHandler(.useCredential, credential)
                action?(.didRecieveAuthChallenge(webView, challenge, .useCredential, credential))
            } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
                completionHandler(.performDefaultHandling, nil)
                action?(.didRecieveAuthChallenge(webView, challenge, .performDefaultHandling, nil))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                action?(.didRecieveAuthChallenge(webView, challenge, .cancelAuthenticationChallenge, nil))
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
            action?(.didRecieveAuthChallenge(webView, challenge, .performDefaultHandling, nil))
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webViewStateModel.loading = true
        action?(.didStartProvisionalNavigation(webView, navigation))
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        action?(.didReceiveServerRedirectForProvisionalNavigation(webView, navigation))
    }
    
    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        webViewStateModel.canGoForward = webView.canGoForward
        action?(.didFailProvisionalNavigation(webView, navigation, error))
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        action?(.didCommit(webView, navigation))
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        webViewStateModel.canGoForward = webView.canGoForward
        if let title = title {
            webViewStateModel.pageTitle = title
        } else {
            if let title = webView.title {
                webViewStateModel.pageTitle = title
            }
        }
        action?(.didFinish(webView, navigation))
    }
    
    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        webViewStateModel.loading = false
        webViewStateModel.canGoBack = webView.canGoBack
        webViewStateModel.canGoForward = webView.canGoForward
        action?(.didFail(webView, navigation, error))
    }
}

@available(iOS 13.0, *)
class WebViewStateModel: ObservableObject {
    @Published var pageTitle: String = "Loading..."
    @Published var loading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var goBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var goForward: Bool = false
    @Published var reload: Bool = false
}

@available(iOS 13.0, *)
public struct WebPresenterView: View {
    public enum NavigationAction {
        case decidePolicy(WKWebView, WKNavigationAction, WKNavigationActionPolicy) //mandatory
        case didRecieveAuthChallenge(WKWebView, URLAuthenticationChallenge, URLSession.AuthChallengeDisposition, URLCredential?) //mandatory
        case didStartProvisionalNavigation(WKWebView, WKNavigation)
        case didReceiveServerRedirectForProvisionalNavigation(WKWebView, WKNavigation)
        case didCommit(WKWebView, WKNavigation)
        case didFinish(WKWebView, WKNavigation)
        case didFailProvisionalNavigation(WKWebView, WKNavigation, Error)
        case didFail(WKWebView, WKNavigation, Error)
    }
    
    @ObservedObject var webViewStateModel: WebViewStateModel
    
    private var actionDelegate: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?
    
    let webViewData: WebViewData
    
    let title: String?
    
    let allowedHosts: [String]?
    let forbiddenHosts: [String]?
    let credential: URLCredential?
    
    public var body: some View {
        WebViewWrapper(
            webViewStateModel: webViewStateModel,
            webViewData: webViewData,
            title: title,
            action: actionDelegate,
            allowedHosts: allowedHosts,
            forbiddenHosts: forbiddenHosts,
            credential: credential
        )
    }
    
    init(
        webViewData: WebViewData,
        webViewStateModel: WebViewStateModel,
        title: String?,
        onNavigationAction: ((_ navigationAction: WebPresenterView.NavigationAction) -> Void)?,
        allowedHosts: [String]?,
        forbiddenHosts: [String]?,
        credential: URLCredential?
    ) {
        self.webViewData = webViewData
        self.webViewStateModel = webViewStateModel
        self.title = title
        self.actionDelegate = onNavigationAction
        self.allowedHosts = allowedHosts
        self.forbiddenHosts = forbiddenHosts
        self.credential = credential
    }
}


struct WebView: View {
    let url: URL
    let name: String
    
    @StateObject private var webViewStateModel: WebViewStateModel = WebViewStateModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        LoadingView(isShowing: .constant(webViewStateModel.loading)) {
            WebPresenterView(
                webViewData: WebViewData.url(url),
                webViewStateModel: webViewStateModel,
                title: name,
                onNavigationAction: { navigationAction in
                    print("Navigation action: \(navigationAction)")
                },
                allowedHosts: nil,
                forbiddenHosts: nil,
                credential: nil
            )
        }
        .navigationBarTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.bottom)
        .deprecatedRefreshable {
            DispatchQueue.main.async {
                self.webViewStateModel.reload.toggle()
            }
        }
    }
}
