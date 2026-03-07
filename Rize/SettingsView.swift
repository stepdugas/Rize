//
//  SettingsView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager = DataManager.shared
    @State private var vibrationEnabled = true
    @State private var notificationsEnabled = true
    
    func checkNotificationStatus() {
        NotificationManager.shared.checkPermissionStatus { granted in
            notificationsEnabled = granted
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 10)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // MARK: - Spotify Section
                    SettingsSectionView(title: "SPOTIFY") {
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "music.note.list")
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Spotify Account")
                                        .foregroundColor(.white)
                                    Text("Not connected")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            Button(action: {
                                // Spotify connect coming soon
                            }) {
                                HStack {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                        .frame(width: 30)
                                    Text("Connect Spotify")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding()
                            }
                        }
                    }
                    
                    // MARK: - Alarms Section
                    SettingsSectionView(title: "ALARMS") {
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .frame(width: 30)
                            Text("Vibration")
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $vibrationEnabled)
                                .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                        }
                        .padding()
                    }
                    
                    // MARK: - Notifications Section
                    SettingsSectionView(title: "NOTIFICATIONS") {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Allow Notifications")
                                    .foregroundColor(.white)
                                Text("Required for alarms to fire")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                                .onChange(of: notificationsEnabled) { oldValue, newValue in
                                    if newValue {
                                        NotificationManager.shared.requestPermission { granted in
                                            notificationsEnabled = granted
                                            if !granted {
                                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                        .padding()
                        .onAppear {
                            checkNotificationStatus()
                        }
                    }
                    
                    // MARK: - App Section
                    SettingsSectionView(title: "APP") {
                        VStack(spacing: 0) {
                            ShareLink(item: "Check out Rize - the Spotify alarm app! 🎵⏰") {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                        .frame(width: 30)
                                    Text("Share Rize")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding()
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                    .frame(width: 30)
                                Text("Version")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                    
                    // MARK: - Legal Section
                    SettingsSectionView(title: "LEGAL") {
                        VStack(spacing: 0) {
                            Button(action: {
                                if let url = URL(string: "https://stepdugas.github.io/rize-legal/privacy.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                        .frame(width: 30)
                                    Text("Privacy Policy")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding()
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            Button(action: {
                                if let url = URL(string: "https://stepdugas.github.io/rize-legal/terms.html") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                        .frame(width: 30)
                                    Text("Terms of Use")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                                .padding()
                            }
                        }
                    }
                    
                    // Footer
                    Text("Rize v1.0.0 · Made with 🎵")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom)
                }
            }
        }
    }
}

// MARK: - Reusable Section Container
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            content
                .background(Color(white: 0.1))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
}
