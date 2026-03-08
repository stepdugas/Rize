//
//  SleepView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct SleepView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var showingAddSchedule = false
    @State private var selectedScheduleIndex: Int? = nil
    
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
                
                if dataManager.sleepSchedules.isEmpty {
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
                    List {
                        ForEach(Array(dataManager.sleepSchedules.enumerated()), id: \.element.id) { index, schedule in
                            SleepRowView(schedule: $dataManager.sleepSchedules[index])
                                .listRowBackground(Color(white: 0.1))
                                .onTapGesture {
                                    selectedScheduleIndex = index
                                }
                        }
                        .onDelete(perform: deleteSchedule)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .sheet(isPresented: $showingAddSchedule) {
            AddSleepView()
        }
        .sheet(item: $selectedScheduleIndex) { index in
            EditSleepView(scheduleIndex: index)
        }
    }
    
    func deleteSchedule(at offsets: IndexSet) {
        dataManager.sleepSchedules.remove(atOffsets: offsets)
    }
}
