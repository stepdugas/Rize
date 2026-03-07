//
//  MusicView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct MusicView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Music")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
                Text("Connect Spotify to get started")
                    .foregroundColor(.gray)
                    .italic()
                
                Spacer()
            }
        }
    }
}
