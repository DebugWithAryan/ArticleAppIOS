//
//  ContentView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
