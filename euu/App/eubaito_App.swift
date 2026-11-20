import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct eubaito_App: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
