//
//  RizeApp.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

@main
struct RizeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Called when user taps the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let songURI = userInfo["songURI"] as? String, !songURI.isEmpty {
            SpotifyManager.shared.playTrack(uri: songURI)
        }
        completionHandler()
    }
    
    // Called when notification arrives while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let songURI = userInfo["songURI"] as? String, !songURI.isEmpty {
            SpotifyManager.shared.playTrack(uri: songURI)
        }
        completionHandler([.banner, .sound])
    }
}
