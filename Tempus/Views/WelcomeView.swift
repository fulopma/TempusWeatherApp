//
//  Welcome.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//
import SwiftUI

struct WelcomeView: View {
    @StateObject var welcomeVM = WelcomeViewModel()
    var body: some View {
        VStack {            
            TextField("Enter your city", text: $welcomeVM.query)
            Button("Find Weather") {
                Task {
                    await welcomeVM.findLocation()
                }
            }
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
