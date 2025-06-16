import NetworkLayer
import SwiftUI

struct WelcomeView: View {
    @StateObject var welcomeVM = WelcomeViewModel()
    @State private var isActive = false
    @State private var path = NavigationPath()
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.6)]),
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
                    Button(action: {
                        Task {
                            await welcomeVM.findLocation()
                            isActive = true
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
                            isActive = true
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
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .shadow(radius: 10)
            }
            .padding()
            .navigationDestination(
                isPresented: $isActive,
                destination: welcomeVM.returnWeatherSummary
            )
        }
    }
}

#Preview {
    WelcomeView()
}
