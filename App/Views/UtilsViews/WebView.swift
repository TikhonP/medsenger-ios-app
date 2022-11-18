//
//  WebView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let request = URLRequest(url: url)
        let wbWebView = WKWebView()
        wbWebView.load(request)
        return wbWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(url: URL(string: "https://google.com")!)
            .edgesIgnoringSafeArea(.bottom)
    }
}
