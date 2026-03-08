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
        TabView(selection: $selectedTab) {
            AlarmsView()
                .tabItem {
                    Label("Alarms", systemImage: "alarm.fill")
                }
                .tag(0)
            
            SleepView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
    }
}
