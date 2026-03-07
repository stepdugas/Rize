//
//  ContentView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // App Title
                Text("RIZE")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 20)
                
                Text("your morning, your music")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }
}

#Preview {
    ContentView()
}
