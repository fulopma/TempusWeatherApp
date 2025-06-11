//
//  Coordinator.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//

import SwiftUI
//
//enum Screen: View {
//    case welcome = WelcomeView()
//    case 
//}

@main
struct Coordinator: App {
    var body: some Scene {
        WindowGroup {
            
            #if DEBUG
            WeatherSummaryView(latitude: 37.77, longitude: -122.419, city: "San Francisco")
            #else
            WelcomeView()
            #endif
        }
    }
}
