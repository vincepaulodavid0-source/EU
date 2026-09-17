import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var controller = ItemController()
    @State private var userClaims: [ClaimItemModel] = []
    
    var body: some View {
        TabView {
            FeedView(feedItems: $controller.feedItems, userClaims: $userClaims)
                .tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
             
            ReportView(controller: controller)
                .tabItem {
                    Label("Report", systemImage: "camera.fill")
                }
             
            ClaimsView(userClaims: $userClaims)
                .tabItem {
                    Label("Claims", systemImage: "doc.text.fill")
                }
             
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(Color(red: 0.6, green: 0, blue: 0))
    }
}
