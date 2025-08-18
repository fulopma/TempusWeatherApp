import SwiftUI
import NewRelic

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var weatherSummaryVM: WeatherSummaryViewModel?
    @Published var weatherDetailsVM: WeatherDetailsViewModel?
    // Called from WelcomeView
    @MainActor func showWeatherSummary(latitude: Double, longitude: Double, city: String, serviceManager: Networking) {
        NewRelic.recordCustomEvent("Show Weather Summary", attributes: [
            "latitude": latitude,
            "longitude": longitude,
            "city": city
        ])
        NewRelic.recordBreadcrumb("Show Weather summary", attributes: [
            "latitude": latitude,
            "longitude": longitude,
            "city": city,
            "serviceManager": String(describing: serviceManager),
            "currentPath": String(describing: path)
        ])
        if city.isEmpty || city == "Location not found" {
            print("Enter in a valid city not <\(city)>")
            NewRelic.recordBreadcrumb("Tried to show weather summary for an empty city")
            return
        }
        let summaryVM = WeatherSummaryViewModel(latitude: latitude,
                                                longitude: longitude,
                                                city: city,
                                                serviceManager: serviceManager)
        let detailsVM = WeatherDetailsViewModel(serviceManager: NetworkManager(),
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
        NewRelic.recordCustomEvent("Show Weather Details")
        NewRelic.recordBreadcrumb("Show Weather Details", attributes: [
            "currentPath": String(describing: path)
        ])
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
