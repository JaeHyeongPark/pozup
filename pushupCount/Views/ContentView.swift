import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var viewModel = PushUpCountViewModel()
    @State private var airPodsModelName: String = "AirPods Pro (Mock)"
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case explore = "Explore"
        case profile = "Profile"

        var systemImageName: String {
            switch self {
            case .home: return "house.fill"
            case .explore: return "magnifyingglass"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: Tab.home.systemImageName)
                }
                .tag(Tab.home)

            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: Tab.explore.systemImageName)
                }
                .tag(Tab.explore)

            Text("Profile View")
                .font(.largeTitle)
                .tabItem {
                    Label("Profile", systemImage: Tab.profile.systemImageName)
                }
                .tag(Tab.profile)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
