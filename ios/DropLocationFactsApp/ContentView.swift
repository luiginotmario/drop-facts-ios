import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        Group {
            if !viewModel.isAuthenticated {
                OnboardingLoginView(viewModel: viewModel)
            } else if !viewModel.hasCompletedOnboarding {
                OnboardingWidgetPreviewView(viewModel: viewModel)
            } else {
                MainTabView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.35), value: viewModel.hasCompletedOnboarding)
        .preferredColorScheme(.light)
    }
}
