import SwiftUI
import NetworkLayer

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var weatherSummaryVM: WeatherSummaryViewModel?
    @Published var weatherDetailsVM: WeatherDetailsViewModel?
    // Called from WelcomeView
    @MainActor func showWeatherSummary(latitude: Double, longitude: Double, city: String, serviceManager: ServiceAPI) {
        if city.isEmpty || city == "Location not found" {
            print("Enter in a valid city not <\(city)>")
            return
        }
        let summaryVM = WeatherSummaryViewModel(latitude: latitude,
                                                longitude: longitude,
                                                city: city,
                                                serviceManager: serviceManager)
        let detailsVM = WeatherDetailsViewModel(serviceManager: ServiceManager(),
                                                latitude: latitude,
                                                longitude: longitude,
                                                city: city,
                                                units: summaryVM.unit)
        self.weatherSummaryVM = summaryVM
        self.weatherDetailsVM = detailsVM
        path.append("WeatherSummary")
    }
    // Called from WeatherSummaryView
    func showWeatherDetails() {
        path.append("WeatherDetails")
    }
    // For navigationDestination
    @ViewBuilder
    func destination(for value: String) -> some View {
        switch value {
        case "WeatherSummary":
            if let summaryVM = weatherSummaryVM, let detailsVM = weatherDetailsVM {
                WeatherSummaryView(weatherSummaryVM: summaryVM, weatherDetailsVM: detailsVM)
                    .environmentObject(self)
            }
        case "WeatherDetails":
            if let detailsVM = weatherDetailsVM {
                ZStack {
                    WeatherDetailsViewControllerWrapper(viewModel: detailsVM)
                        .edgesIgnoringSafeArea(.all)
                        .navigationTitle(detailsVM.city)
                }
            }
        default:
            EmptyView()
        }
    }
}
