import NetworkLayer
//
//  Welcome.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//
import SwiftUI

struct WelcomeView: View {
    @StateObject var welcomeVM = WelcomeViewModel()
    @State private var isActive = false
    @State private var path = NavigationPath()
    init() {
    }
    var body: some View {
        VStack {
            TextField("Enter your city", text: $welcomeVM.query)
            Button("Find Weather") {
                Task {
                    await welcomeVM.findLocation()
                    isActive = true
                }
            }.navigationDestination(
                isPresented: $isActive,
                destination: welcomeVM.returnWeatherSummary
            )
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
