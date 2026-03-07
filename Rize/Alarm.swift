//
//  Alarm.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation

struct Alarm: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var label: String
    var isEnabled: Bool
    var songName: String
    var songURI: String
    var repeatDays: [String]
    var snoozeDuration: Int
}
