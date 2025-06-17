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
    @State private var ranOnce = false
    init(latitude: Double, longitude: Double, city: String, serviceManager: ServiceAPI) {
        self.weatherSummaryVM =
        WeatherSummaryViewModel(
            latitude: latitude,
            longitude: longitude,
            city: city,
            serviceManager: serviceManager)
        self.weatherDetailsVM = WeatherDetailsViewModel(
            serviceManager: ServiceManager(),
            latitude: latitude,
            longitude: longitude,
            city: city,
            units: .usCustomary)
    }
    var body: some View {
        ZStack {
            // Gradient background based on temperature color
            LinearGradient(
                gradient: Gradient(colors: [weatherSummaryVM.getColorTemperature(), .white, weatherSummaryVM.getColorTemperature().opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 24) {
                Text(weatherSummaryVM.city)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(1), radius: 15, x: 1, y: 4)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.white.opacity(0.18), lineWidth: 2)
//                    )
                VStack(spacing: 12) {
                    Text(weatherSummaryVM.getTemperatureFormatted())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    Text(weatherSummaryVM.getPrecipationFormatted())
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    Text(weatherSummaryVM.getSmogFormatted())
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.vertical, 8)
                Button {
                    showVC.toggle()
                } label: {
                    Text("Show Historical Weather")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(radius: 6)
                }
                .navigationDestination(isPresented: $showVC) {
                    WeatherDetailsViewControllerWrapper(viewModel: weatherDetailsVM)
                }
            }
            .padding(32)
            .background(Color.white.opacity(0.08))
            .cornerRadius(28)
            .shadow(radius: 16)
        }
        .task {
           weatherDetailsVM.fetchWeatherData()
        }
    }
}

#Preview {
    WeatherSummaryView(latitude: 37.77, longitude: -122.42, city: "San Francisco, CA", serviceManager: ServiceManager())
}
