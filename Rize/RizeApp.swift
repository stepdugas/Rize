//
//  RizeApp.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

@main
struct RizeApp: App {
    init() {
        NotificationManager.shared.requestPermission { granted in
            print(granted ? "Notifications granted ✅" : "Notifications denied ❌")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onOpenURL { url in
                    SpotifyManager.shared.handleURL(url)
                }
        }
    }
}
