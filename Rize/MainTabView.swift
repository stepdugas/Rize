//
//  MainTabView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Swipeable pages
            TabView(selection: $selectedTab) {
                AlarmsView()
                    .tag(0)
                
                SleepView()
                    .tag(1)
                
                SettingsView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom tab bar
            HStack {
                Spacer()
                
                Button(action: { withAnimation { selectedTab = 0 } }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 0 ? "alarm.fill" : "alarm")
                            .font(.system(size: 22))
                        Text("Alarms")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == 0 ?
                        Color(red: 0.0, green: 0.9, blue: 0.4) : .gray)
                }
                
                Spacer()
                
                Button(action: { withAnimation { selectedTab = 1 } }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 1 ? "moon.fill" : "moon")
                            .font(.system(size: 22))
                        Text("Sleep")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == 1 ?
                        Color(red: 0.0, green: 0.9, blue: 0.4) : .gray)
                }
                
                Spacer()
                
                Button(action: { withAnimation { selectedTab = 2 } }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                            .font(.system(size: 22))
                        Text("Settings")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(selectedTab == 2 ?
                        Color(red: 0.0, green: 0.9, blue: 0.4) : .gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color(white: 0.07))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .top
            )
        }
    }
}
