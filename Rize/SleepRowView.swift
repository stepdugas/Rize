//
//  SleepRowView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct SleepRowView: View {
    @Binding var schedule: SleepSchedule
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                // Label
                Text(schedule.label.isEmpty ? "Sleep" : schedule.label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(schedule.isEnabled ? .white : .gray)
                
                // Time range
                HStack(spacing: 4) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 11))
                    Text(timeString(from: schedule.startTime))
                        .font(.system(size: 28, weight: .light, design: .rounded))
                }
                .foregroundColor(schedule.isEnabled ? .white : .gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 11))
                    Text(timeString(from: schedule.endTime))
                        .font(.system(size: 14))
                }
                .foregroundColor(schedule.isEnabled ? .gray : .gray.opacity(0.5))
                
                // Playlist name
                if !schedule.playlistName.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 11))
                        Text(schedule.playlistName)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(schedule.isEnabled ?
                        Color(red: 0.0, green: 0.9, blue: 0.4) : .gray.opacity(0.5))
                }
                
                // Fade out badge
                if schedule.fadeOut {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.1.fill")
                            .font(.system(size: 11))
                        Text("Fades out over \(schedule.fadeOutDuration) min")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $schedule.isEnabled)
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
