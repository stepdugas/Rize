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
                        ForEach($dataManager.alarms) { $alarm in
                            AlarmRowView(alarm: $alarm)
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
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        dataManager.alarms.remove(atOffsets: offsets)
    }
}
