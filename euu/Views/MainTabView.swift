import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var controller: ItemController

    var body: some View {
        TabView {
            FeedView(controller: controller)
                .tabItem { Label("Feed", systemImage: "newspaper") }

            ReportView(controller: controller)
                .tabItem { Label("Report", systemImage: "camera.fill") }

            ClaimsView(userClaims: $controller.claims)
                .tabItem { Label("Claims", systemImage: "doc.text.fill") }

            ProfileView(isLoggedIn: $isLoggedIn, controller: controller)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(.brandRed)
    }
}
