//
//  HealthView.swift
//  Tempus
//
//  Created by Marcell Fulop on 8/6/25.
//

import SwiftUI

struct HealthView: View {
//    @StateObject private var healthViewModel?
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await HealthViewModel()
            }
    }
}

#Preview {
    HealthView()
}
