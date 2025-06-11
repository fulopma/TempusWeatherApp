//
//  WeatherSummary.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import SwiftUI

struct WeatherSummaryView: View {
    @ObservedObject var weatherSummaryVM: WeatherSummaryViewModel
    init(latitude: Double, longitude: Double, city: String) {
        self.weatherSummaryVM = WeatherSummaryViewModel(latitude: latitude, longitude: longitude, city: city)
    }
    var body: some View {
        VStack {
            Text(weatherSummaryVM.city)
            Text(weatherSummaryVM.getTemperatureFormatted())
        }
        .padding()
    }
}

#Preview {
    WeatherSummaryView(latitude: 37.77, longitude: 122.42, city: "San Francisco")
}

