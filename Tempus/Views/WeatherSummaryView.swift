import SwiftUI
import NetworkLayer

struct WeatherSummaryView: View {
    @ObservedObject var weatherSummaryVM: WeatherSummaryViewModel
    @ObservedObject var weatherDetailsVM: WeatherDetailsViewModel
    @State private var selectedUnit: Units = .usCustomary
    @EnvironmentObject var coordinator: Coordinator

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors:
                    [weatherSummaryVM.getColorTemperature(),
                    .white,
                    weatherSummaryVM.getColorTemperature().opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Picker("", selection: $selectedUnit) {
                        Text("US").tag(Units.usCustomary)
                        Text("Metric").tag(Units.metric)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 160)
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.top, 8)
                .padding(.horizontal, 8)
                .onChange(of: selectedUnit) {
                   weatherSummaryVM.unit = selectedUnit
                }

                Text(weatherSummaryVM.city)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(1), radius: 15, x: 1, y: 4)
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
                    coordinator.showWeatherDetails()
                    weatherDetailsVM.units = selectedUnit
                } label: {
                    Text("Show Historical Weather")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(radius: 6)
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
        .onAppear {
            selectedUnit = weatherSummaryVM.unit
        }
    }
}

// Use this preview only for design, not for navigation testing
#Preview {
    WeatherSummaryView(
        weatherSummaryVM: WeatherSummaryViewModel(
            latitude: 37.77,
            longitude: -122.42,
            city: "San Francisco, CA",
            serviceManager: ServiceManager()
        ),
        weatherDetailsVM: WeatherDetailsViewModel(
            serviceManager: ServiceManager(),
            latitude: 37.77,
            longitude: -122.42,
            city: "San Francisco, CA",
            units: .usCustomary
        )
    )
}
