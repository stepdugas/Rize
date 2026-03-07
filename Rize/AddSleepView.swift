//
//  AddSleepView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AddSleepView: View {
    @Binding var schedules: [SleepSchedule]
    @Environment(\.dismiss) var dismiss
    
    @State private var label = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var fadeOut = false
    @State private var fadeOutDuration = 15
    
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
                        
                        Text("New Sleep Schedule")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Save") {
                            saveSchedule()
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Label Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("LABEL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        TextField("e.g. Bedtime, Nap, Wind Down...", text: $label)
                            .padding()
                            .background(Color(white: 0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    
                    // Start Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MUSIC STARTS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .frame(maxWidth: .infinity)
                    }
                    
                    // End Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("MUSIC STOPS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Fade Out Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FADE OUT")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Fade out music")
                                        .foregroundColor(.white)
                                    Text("Gradually lower volume before stopping")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $fadeOut)
                                    .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                            }
                            
                            if fadeOut {
                                HStack {
                                    Text("Fade duration: \(fadeOutDuration) min")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Stepper("", value: $fadeOutDuration, in: 5...60, step: 5)
                                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                                }
                            }
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
    }
    
    func saveSchedule() {
        let newSchedule = SleepSchedule(
            startTime: startTime,
            endTime: endTime,
            label: label,
            isEnabled: true,
            playlistName: "",
            playlistURI: "",
            fadeOut: fadeOut,
            fadeOutDuration: fadeOutDuration
        )
        schedules.append(newSchedule)
        dismiss()
    }
}
