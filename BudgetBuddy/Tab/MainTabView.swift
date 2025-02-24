import SwiftUI

struct MainTabView: View {
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color(hex: "191919")) 
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    @EnvironmentObject var authViewModel : AuthViewModel
    var body: some View {
        TabView {
            HomeMainView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            .environmentObject(authViewModel)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            InsightMainView()
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.min")
                }
            Settings()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .environmentObject(authViewModel)
            TestAIView()
                .tabItem {
                    Label("Profile", systemImage: "square.and.arrow.up")
                }

        }
        .tint(.green) // Set active tab color to green
    }
}







#Preview {
    MainTabView()
}
