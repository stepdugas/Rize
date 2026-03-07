//
//  Untitled.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct AlarmsView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Text("Alarms")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                    .shadow(color: Color(red: 0.0, green: 0.9, blue: 0.4), radius: 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
                Text("No alarms yet")
                    .foregroundColor(.gray)
                    .italic()
                
                Spacer()
            }
        }
    }
}
