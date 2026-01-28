//
//  Mundo_planalto_Portal_AppApp.swift
//  Mundo planalto Portal App
//
//  Created by matheus ferreira on 26/01/26.
//

import SwiftUI

@main
struct Mundo_planalto_Portal_AppApp: App {
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn || UserDefaults.standard.string(forKey: "auth_token") != nil {
                MainTabView()
            } else {
                NavigationStack {
                    LoginView()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserLoggedIn"))) { _ in
                    isLoggedIn = true
                }
            }
        }
    }
}
