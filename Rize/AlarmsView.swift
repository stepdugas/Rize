//
//  Untitled.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AlarmsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingAddAlarm = false
    @State private var selectedAlarmIndex: Int? = nil
    @State private var showDNDTip = !UserDefaults.standard.bool(forKey: "hasSeenDNDTip")
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("Alarms")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 10)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddAlarm = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // DND Tip Card
                if showDNDTip {
                    HStack(spacing: 12) {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Allow Rize through Focus mode")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Settings → Focus → Do Not Disturb → Apps → Add Rize")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showDNDTip = false
                            }
                            UserDefaults.standard.set(true, forKey: "hasSeenDNDTip")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                        }
                    }
                    .padding()
                    .background(Color(white: 0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                if dataManager.alarms.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "alarm")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No alarms yet")
                            .foregroundColor(.gray)
                            .italic()
                        Text("Tap + to create your first alarm")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 14))
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(dataManager.alarms.enumerated()), id: \.element.id) { index, alarm in
                            AlarmRowView(alarm: $dataManager.alarms[index]) {
                                selectedAlarmIndex = index
                            }
                            .listRowBackground(Color(white: 0.1))
                        }
                        .onDelete(perform: deleteAlarm)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $showingAddAlarm) {
            AddAlarmView()
        }
        .sheet(item: $selectedAlarmIndex) { index in
            EditAlarmView(alarmIndex: index)
        }
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        offsets.forEach { index in
            let alarm = dataManager.alarms[index]
            NotificationManager.shared.cancelAlarm(alarm)
        }
        dataManager.alarms.remove(atOffsets: offsets)
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
