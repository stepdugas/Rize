//
//  AddSleepView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AddSleepView: View {
    @ObservedObject var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var label = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var fadeOut = false
    @State private var fadeOutDuration = 15
    @State private var selectedPlaylist: PlaylistResult? = nil
    @State private var showingPlaylistPicker = false
    
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
                    
                    // Sleep Playlist
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SLEEP PLAYLIST")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingPlaylistPicker = true
                        }) {
                            HStack {
                                Image(systemName: "music.note.list")
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    if let playlist = selectedPlaylist {
                                        Text(playlist.name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 15))
                                        Text("\(playlist.trackCount) songs")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 12))
                                    } else {
                                        Text("Pick a playlist")
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
        .sheet(isPresented: $showingPlaylistPicker) {
            PlaylistPickerView { playlist in
                selectedPlaylist = playlist
            }
        }
    }
    
    func saveSchedule() {
        let newSchedule = SleepSchedule(
            startTime: startTime,
            endTime: endTime,
            label: label,
            isEnabled: true,
            playlistName: selectedPlaylist?.name ?? "",
            playlistURI: selectedPlaylist?.uri ?? "",
            fadeOut: fadeOut,
            fadeOutDuration: fadeOutDuration
        )
        dataManager.sleepSchedules.append(newSchedule)
        dismiss()
    }
}
