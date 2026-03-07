//
//  SleepView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct SleepView: View {
    @State private var schedules: [SleepSchedule] = []
    @State private var showingAddSchedule = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("Sleep")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                        .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 10)
                    
                    Spacer()
                    
                    // Add Schedule Button
                    Button(action: {
                        showingAddSchedule = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 8)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if schedules.isEmpty {
                    // Empty state
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No sleep schedule yet")
                            .foregroundColor(.gray)
                            .italic()
                        Text("Tap + to create your first sleep schedule")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 14))
                    }
                    Spacer()
                } else {
                    // Schedule List
                    List {
                        ForEach($schedules) { $schedule in
                            SleepRowView(schedule: $schedule)
                                .listRowBackground(Color(white: 0.1))
                        }
                        .onDelete(perform: deleteSchedule)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $showingAddSchedule) {
            AddSleepView(schedules: $schedules)
        }
    }
    
    func deleteSchedule(at offsets: IndexSet) {
        schedules.remove(atOffsets: offsets)
    }
}
