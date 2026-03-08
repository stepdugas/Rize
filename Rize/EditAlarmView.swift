//
//  EditAlarmView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/8/26.
//

import SwiftUI

struct EditAlarmView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    var alarmIndex: Int
    
    @State private var selectedTime: Date
    @State private var label: String
    @State private var repeatDays: [String]
    @State private var snoozeDuration: Int
    @State private var selectedSongName: String
    @State private var selectedSongURI: String
    @State private var showingSongPicker = false
    
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    init(alarmIndex: Int) {
        self.alarmIndex = alarmIndex
        let alarm = DataManager.shared.alarms[alarmIndex]
        _selectedTime = State(initialValue: alarm.time)
        _label = State(initialValue: alarm.label)
        _repeatDays = State(initialValue: alarm.repeatDays)
        _snoozeDuration = State(initialValue: alarm.snoozeDuration)
        _selectedSongName = State(initialValue: alarm.songName)
        _selectedSongURI = State(initialValue: alarm.songURI)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text("Edit Alarm")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Save") {
                            saveAlarm()
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Time Picker
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .frame(maxWidth: .infinity)
                    
                    // Label Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LABEL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        TextField("e.g. Work, Gym, School...", text: $label)
                            .padding()
                            .background(Color(white: 0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    
                    // Repeat Days
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REPEAT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        HStack(spacing: 8) {
                            ForEach(days, id: \.self) { day in
                                let isSelected = repeatDays.contains(day)
                                Button(action: {
                                    if isSelected {
                                        repeatDays.removeAll { $0 == day }
                                    } else {
                                        repeatDays.append(day)
                                    }
                                }) {
                                    Text(day)
                                        .font(.system(size: 13, weight: .medium))
                                        .frame(width: 40, height: 40)
                                        .background(isSelected ?
                                            Color(red: 0.0, green: 0.9, blue: 0.4) : Color(white: 0.15))
                                        .foregroundColor(isSelected ? .black : .gray)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Snooze Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SNOOZE DURATION")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("\(snoozeDuration) minutes")
                                .foregroundColor(.white)
                            Spacer()
                            Stepper("", value: $snoozeDuration, in: 1...30)
                                .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                        }
                        .padding()
                        .background(Color(white: 0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Wake Up Song
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WAKE UP SONG")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingSongPicker = true
                        }) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    if !selectedSongName.isEmpty {
                                        Text(selectedSongName)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15))
                                    } else {
                                        Text("Pick a song")
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            .padding()
                            .background(Color(white: 0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingSongPicker) {
            SongPickerView { track in
                selectedSongName = track.name
                selectedSongURI = track.uri
            }
        }
    }
    
    func saveAlarm() {
        NotificationManager.shared.cancelAlarm(dataManager.alarms[alarmIndex])
        dataManager.alarms[alarmIndex].time = selectedTime
        dataManager.alarms[alarmIndex].label = label
        dataManager.alarms[alarmIndex].repeatDays = repeatDays
        dataManager.alarms[alarmIndex].snoozeDuration = snoozeDuration
        dataManager.alarms[alarmIndex].songName = selectedSongName
        dataManager.alarms[alarmIndex].songURI = selectedSongURI
        dataManager.sortAlarms()
        NotificationManager.shared.scheduleAlarm(dataManager.alarms[alarmIndex])
        dismiss()
    }
}
