//
//  DataManager.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var alarms: [Alarm] = [] {
        didSet { saveAlarms() }
    }
    
    @Published var sleepSchedules: [SleepSchedule] = [] {
        didSet { saveSleepSchedules() }
    }
    
    init() {
        loadAlarms()
        loadSleepSchedules()
    }
    
    // MARK: - Alarms
    func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: "savedAlarms")
        }
    }
    
    func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: "savedAlarms"),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
        }
    }
    
    func sortAlarms() {
        alarms.sort { $0.time < $1.time }
    }
    
    // MARK: - Sleep Schedules
    func saveSleepSchedules() {
        if let encoded = try? JSONEncoder().encode(sleepSchedules) {
            UserDefaults.standard.set(encoded, forKey: "savedSleepSchedules")
        }
    }
    
    func loadSleepSchedules() {
        if let data = UserDefaults.standard.data(forKey: "savedSleepSchedules"),
           let decoded = try? JSONDecoder().decode([SleepSchedule].self, from: data) {
            sleepSchedules = decoded
        }
    }
}
