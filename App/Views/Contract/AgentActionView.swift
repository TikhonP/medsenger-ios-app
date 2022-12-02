//
//  AgentActionView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct AgentActionView: View {
    let url: URL
    let name: String
    let webViewModel = WebViewViewModel()
    
    var body: some View {
        ZStack {
            if webViewModel.isLoaderVisible {
                ProgressView()
            }
            WebView(url: url, viewModel: webViewModel)
        }
        .navigationBarTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct AgentActionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AgentActionView(url: URL(string: "https://www.google.com/")!, name: "google")
        }
    }
}
