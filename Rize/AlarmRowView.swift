//
//  AlarmRowView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AlarmRowView: View {
    @Binding var alarm: Alarm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Time
                Text(timeString(from: alarm.time))
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundColor(alarm.isEnabled ? .white : .gray)
                
                // Label
                Text(alarm.label.isEmpty ? "Alarm" : alarm.label)
                    .font(.system(size: 14))
                    .foregroundColor(alarm.isEnabled ? .white.opacity(0.7) : .gray.opacity(0.5))
                
                // Song name
                if !alarm.songName.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .font(.system(size: 11))
                        Text(alarm.songName)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(alarm.isEnabled ?
                        Color(red: 0.0, green: 0.9, blue: 0.4) : .gray.opacity(0.5))
                }
                
                // Repeat days
                if !alarm.repeatDays.isEmpty {
                    Text(alarm.repeatDays.joined(separator: " · "))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $alarm.isEnabled)
                .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
        }
        .padding(.vertical, 8)
    }
    
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
