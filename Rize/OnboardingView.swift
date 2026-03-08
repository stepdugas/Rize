//
//  OnboardingView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/8/26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1 - Welcome
                WelcomePage()
                    .tag(0)
                
                // Page 2 - Features
                FeaturesPage()
                    .tag(1)
                
                // Page 3 - DND
                DNDPage()
                    .tag(2)
                
                // Page 4 - Spotify
                SpotifyPage(onComplete: onComplete)
                    .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Skip button
            VStack {
                HStack {
                    Spacer()
                    if currentPage < 3 {
                        Button("Skip") {
                            onComplete()
                        }
                        .foregroundColor(.gray)
                        .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Page 1: Welcome
struct WelcomePage: View {
    @State private var glowRadius = 10.0
    @State private var opacity = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("RIZE")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: glowRadius)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowRadius = 30.0
                    }
                    withAnimation(.easeIn(duration: 0.8)) {
                        opacity = 1.0
                    }
                }
            
            VStack(spacing: 12) {
                Text("Wake up to your music")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("The alarm app that plays your favorite Spotify songs when it's time to get up")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(opacity)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 2: Features
struct FeaturesPage: View {
    @State private var opacity = 0.0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Two powerful features")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                FeatureCard(
                    icon: "alarm.fill",
                    title: "Alarms",
                    description: "Set a wake up alarm with your favorite Spotify song. Never wake up to a boring beep again."
                )
                
                FeatureCard(
                    icon: "moon.fill",
                    title: "Sleep",
                    description: "Wind down with a playlist that automatically stops playing when you're ready to sleep."
                )
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(white: 0.08))
        .cornerRadius(16)
    }
}

// MARK: - Page 3: DND
struct DNDPage: View {
    @State private var opacity = 0.0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "moon.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 12) {
                Text("Don't let DND silence your alarm")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("To make sure Rize always wakes you up, allow it to send notifications through Focus mode")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                DNDStep(number: "1", text: "Open iPhone **Settings**")
                DNDStep(number: "2", text: "Tap **Focus**")
                DNDStep(number: "3", text: "Tap **Do Not Disturb**")
                DNDStep(number: "4", text: "Tap **Apps** under \"Allow Notifications From\"")
                DNDStep(number: "5", text: "Add **Rize**")
            }
            .padding()
            .background(Color(white: 0.08))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}

struct DNDStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.2))
                    .frame(width: 28, height: 28)
                Text(number)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
            }
            
            Text(LocalizedStringKey(text))
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}

// MARK: - Page 4: Spotify
struct SpotifyPage: View {
    var onComplete: () -> Void
    @State private var opacity = 0.0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: "music.note.list")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
            }
            
            VStack(spacing: 12) {
                Text("Connect your Spotify")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("You'll need Spotify installed on your iPhone. Free or Premium both work!")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 16) {
                // Connect button
                Button(action: {
                    SpotifyManager.shared.connect()
                    onComplete()
                }) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                        Text("Connect Spotify")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .cornerRadius(30)
                    .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4).opacity(0.5), radius: 15)
                }
                .padding(.horizontal, 32)
                
                // Skip button
                Button(action: {
                    onComplete()
                }) {
                    Text("Skip for now")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}
