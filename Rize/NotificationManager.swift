//
//  NotificationManager.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    // Request permission from the user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // Check current permission status
    func checkPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // Schedule a notification for an alarm
    func scheduleAlarm(_ alarm: Alarm) {
        guard alarm.isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Rize Alarm" : alarm.label
        content.body = alarm.songName.isEmpty ?
            "Time to wake up! 🎵" :
            "Time to wake up! Now playing \(alarm.songName) 🎵"
        content.sound = .default
        
        // Get hour and minute from alarm time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: alarm.time)
        
        if alarm.repeatDays.isEmpty {
            // One-time alarm
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        } else {
            // Repeating alarm — schedule for each selected day
            let dayMap = ["Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4,
                         "Thu": 5, "Fri": 6, "Sat": 7]
            
            for day in alarm.repeatDays {
                if let weekday = dayMap[day] {
                    var repeatingComponents = components
                    repeatingComponents.weekday = weekday
                    
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: repeatingComponents,
                        repeats: true
                    )
                    let request = UNNotificationRequest(
                        identifier: "\(alarm.id.uuidString)-\(day)",
                        content: content,
                        trigger: trigger
                    )
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    // Cancel a specific alarm's notifications
    func cancelAlarm(_ alarm: Alarm) {
        let dayMap = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        var identifiers = [alarm.id.uuidString]
        for day in dayMap {
            identifiers.append("\(alarm.id.uuidString)-\(day)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
    
    // Cancel all scheduled notifications
    func cancelAllAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

