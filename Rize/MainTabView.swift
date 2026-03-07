//
//  MainTabView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            AlarmsView()
                .tabItem {
                    Label("Alarms", systemImage: "alarm.fill")
                }
            
            SleepView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
    }
}
