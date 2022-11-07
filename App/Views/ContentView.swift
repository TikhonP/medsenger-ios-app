//
//  ContentView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.10.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var contentViewModel = ContentViewModel()
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    var body: some View {
        if let user = users.first {
            ZStack {
                if user.role == nil {
                    ChooseRoleView()
                } else {
                    ChatsView()
                }
            }
            .onAppear(perform:  Login.shared.deauthIfTokenIsNotExists)
        } else {
            SignInView()
                .onAppear(perform: PersistenceController.clearDatabase)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
