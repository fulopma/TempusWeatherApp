//
//  WeatherSummary.swift
//  Tempus
//
//  Created by Marcell Fulop on 6/4/25.
//
import SwiftUI
import NetworkLayer

struct WeatherSummaryView: View {
    @ObservedObject var weatherSummaryVM: WeatherSummaryViewModel
    @ObservedObject var weatherDetailsVM: WeatherDetailsViewModel
    @State private var showVC = false
    init(latitude: Double, longitude: Double, city: String, serviceManager: ServiceAPI) {
        self.weatherSummaryVM =
        WeatherSummaryViewModel(
            latitude: latitude,
            longitude: longitude,
            city: city,
            serviceManager: serviceManager)
        self.weatherDetailsVM = WeatherDetailsViewModel(
            serviceManager: serviceManager,
            latitude: latitude,
            longitude: longitude,
            city: city,
            units: .usCustomary)
    }
    var body: some View {
        ZStack {
            weatherSummaryVM.getColorTemperature().ignoresSafeArea()
            VStack {
                Text(weatherSummaryVM.city)
                Text(weatherSummaryVM.getTemperatureFormatted())
                Button {
                    // action
                    showVC = true
                }label: {
                    Text("Show Details")
                        .foregroundStyle(.white)
                        .padding()
                }
                .navigationDestination(isPresented: $showVC) {
                    WeatherDetailsViewControllerWrapper(viewModel: weatherDetailsVM)
                }
                .background(Color.accentColor)
                .cornerRadius(5)
            }
            .padding()
            .task {
                weatherDetailsVM.fetchWeatherData()
            }
        }
    }
}

#Preview {
    WeatherSummaryView(latitude: 37.77, longitude: -122.42, city: "San Francisco", serviceManager: ServiceManager())
}
