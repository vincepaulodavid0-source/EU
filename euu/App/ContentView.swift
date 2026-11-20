import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var activeRole = "Student"
    @State private var checkingSession = true
    @StateObject private var controller = ItemController()
    @AppStorage("darkMode") private var darkMode = false

    var body: some View {
        Group {
            if checkingSession {
                ProgressView()
            } else if isLoggedIn {
                switch activeRole {
                case "Staff": StaffTabView(isLoggedIn: $isLoggedIn, controller: controller)
                case "Admin": AdminTabView(isLoggedIn: $isLoggedIn, controller: controller)
                default:      MainTabView(isLoggedIn: $isLoggedIn, controller: controller)
                }
            } else {
                LoginView(isLoggedIn: $isLoggedIn, activeRole: $activeRole)
            }
        }
        .preferredColorScheme(darkMode ? .dark : nil)
        .task { await restoreSession() }
        .onChange(of: isLoggedIn) { _, loggedIn in
            if loggedIn {
                Task { await startController() }
            } else {
                controller.stop()
                AuthService.shared.signOut()
            }
        }
        .alert("Something went wrong",
               isPresented: Binding(
                get: { controller.errorMessage != nil },
                set: { if !$0 { controller.errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }

    private func restoreSession() async {
        if let current = Auth.auth().currentUser,
           let profile = try? await AuthService.shared.loadProfile(uid: current.uid) {
            activeRole = profile.role
            isLoggedIn = true
        }
        checkingSession = false
    }

    private func startController() async {
        guard let current = Auth.auth().currentUser,
              let profile = try? await AuthService.shared.loadProfile(uid: current.uid) else { return }
        controller.start(user: profile)
    }
}
