import NetworkLayer
import SwiftUI

struct WelcomeView: View {
    @StateObject var welcomeVM = WelcomeViewModel()
    @EnvironmentObject var coordinator: Coordinator
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.7), Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Welcome to Tempus")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                VStack(spacing: 16) {
                    TextField("Enter your city", text: $welcomeVM.query)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .font(.title2)
                        .autocapitalization(.words)
                        .foregroundStyle(Color.black)
                    Button(action: {
                        Task {
                            await welcomeVM.findLocation()
                            coordinator.showWeatherSummary(
                                latitude: welcomeVM.latitude,
                                longitude: welcomeVM.longitude,
                                city: welcomeVM.city
                                    + (welcomeVM.administrativeArea.isEmpty
                                        ? ""
                                        : ", \(welcomeVM.administrativeArea)"),
                                serviceManager: ServiceManager()
                            )
                        }
                    }) {
                        Text("Find Weather")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        Task {
                            await welcomeVM.useCurrentLocation()
                            coordinator.showWeatherSummary(
                                latitude: welcomeVM.latitude,
                                longitude: welcomeVM.longitude,
                                city: welcomeVM.city
                                    + (welcomeVM.administrativeArea.isEmpty
                                        ? ""
                                        : ", \(welcomeVM.administrativeArea)"),
                                serviceManager: ServiceManager()
                            )
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Use Current Location")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    Button(action: {
                        if let windowScene = UIApplication.shared
                            .connectedScenes.first as? UIWindowScene,
                            let rootVC = windowScene.windows.first?
                                .rootViewController {
                            let ackVC = UIHostingController(
                                rootView: AcknowlegementsViewControllerWrapper()
                            )
                            ackVC.modalPresentationStyle = .formSheet
                            rootVC.present(
                                ackVC,
                                animated: true,
                                completion: nil
                            )
                        }
                    })
                    {
                        Text("Acknowledgements")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Color(.systemYellow).opacity(0.25))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.brown.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView()
}
