//
//  AddAlarmView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AddAlarmView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTime = Date()
    @State private var label = ""
    @State private var repeatDays: [String] = []
    @State private var snoozeDuration = 9
    
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("New Alarm")
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
                
                Spacer()
            }
        }
    }
    
    func saveAlarm() {
        let newAlarm = Alarm(
            time: selectedTime,
            label: label,
            isEnabled: true,
            songName: "",
            songURI: "",
            repeatDays: repeatDays,
            snoozeDuration: snoozeDuration
        )
        dataManager.alarms.append(newAlarm)
        dataManager.sortAlarms()
        NotificationManager.shared.scheduleAlarm(newAlarm)
        dismiss()
    }
}
