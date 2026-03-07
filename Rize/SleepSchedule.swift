//
//  SleepSchedule.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation

struct SleepSchedule: Identifiable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    var label: String
    var isEnabled: Bool
    var playlistName: String
    var playlistURI: String
    var fadeOut: Bool
    var fadeOutDuration: Int
}
