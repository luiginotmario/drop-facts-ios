import SwiftUI

struct MainTabView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        if #available(iOS 26.0, *) {
            tabContent
        } else {
            tabContent
        }
    }

    private var tabContent: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    HomeView(viewModel: viewModel)
                }
            }

            Tab("Explore", systemImage: "bubble.left.and.text.bubble.right") {
                NavigationStack {
                    ChatView(viewModel: viewModel)
                }
            }
        }
        .tint(.blue)
    }
}
