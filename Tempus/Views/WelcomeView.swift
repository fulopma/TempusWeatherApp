//
//  Welcome.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/3/25.
//
import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
