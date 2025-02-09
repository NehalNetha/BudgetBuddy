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
            
            CalendarView()
                .tabItem {
                    Label("Search", systemImage: "calendar")
                }
            
            InsightMainView()
                .tabItem {
                    Label("Profile", systemImage: "lightbulb.min")
                }
            VStack{
                Button{
                    authViewModel.signOut()

                }label: {
                    Text("Sign Out")
                }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .tint(.green) // Set active tab color to green
    }
}







#Preview {
    MainTabView()
}
