//
//  LaunchScreenView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/8/26.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var opacity = 0.0
    @State private var glowRadius = 10.0
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                Text("RIZE")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: glowRadius)
                
                Text("your morning, your music")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .italic()
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1.0
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowRadius = 30.0
                }
            }
        }
    }
}
