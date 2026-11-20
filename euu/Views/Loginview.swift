import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var activeRole: String

    @State private var selectedRole = "Student"
    @State private var isSignUp = false

    @State private var fullName = ""
    @State private var schoolId = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    let roles = ["Student", "Admin", "Staff"]
    let customRed = Color(red: 0.6, green: 0, blue: 0)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    header

                    Picker("Role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedRole) { _, newRole in
                        if newRole != "Student" { isSignUp = false }
                    }

                    
                    if selectedRole == "Student" {
                        Picker("Mode", selection: $isSignUp) {
                            Text("Login").tag(false)
                            Text("Sign Up").tag(true)
                        }
                        .pickerStyle(.segmented)
                    } else {
                        Text("\(selectedRole) accounts are created by the administrator.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        if isSignUp {
                            labeled("Full name") {
                                TextField("e.g., Juan Dela Cruz", text: $fullName)
                                    .textContentType(.name)
                            }
                            labeled("School ID") {
                                TextField("e.g., A24-0000", text: $schoolId)
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                            }
                        }

                        labeled("Gmail") {
                            TextField("yourname@gmail.com", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }

                        labeled("Password") {
                            HStack {
                                if showPassword {
                                    TextField("••••••••", text: $password)
                                } else {
                                    SecureField("••••••••", text: $password)
                                }
                                Button { showPassword.toggle() } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        }

                        if isSignUp {
                            labeled("Confirm password") {
                                SecureField("••••••••", text: $confirmPassword)
                            }
                        } else {
                            HStack {
                                Spacer()
                                Button("Forgot credentials?") { forgotPassword() }
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(customRed)
                            }
                        }
                    }

                    Button(action: submit) {
                        ZStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isSignUp ? "Create Account" : "Log In")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customRed.opacity(isLoading ? 0.6 : 1))
                        .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    .padding(.top, 6)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    
    private var header: some View {
        VStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
            VStack(spacing: 4) {
                Text("EU ba'to?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(customRed)
                Text("University Lost & Found Registry")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 30)
    }

    private func labeled<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
            content()
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        }
    }

    
    private func submit() {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        if cleanEmail.isEmpty || password.isEmpty {
            show("Missing info", "Enter your Gmail and password.")
            return
        }

        if isSignUp {
            let name = fullName.trimmingCharacters(in: .whitespaces)
            let sid = schoolId.trimmingCharacters(in: .whitespaces)
            if name.isEmpty || sid.isEmpty {
                show("Missing info", "Enter your full name and school ID.")
                return
            }
            if !cleanEmail.hasSuffix("@gmail.com") {
                show("Use Gmail", "Sign up with a Gmail address (name@gmail.com).")
                return
            }
            if password.count < 6 {
                show("Weak password", "Use at least 6 characters.")
                return
            }
            if password != confirmPassword {
                show("Passwords don't match", "Re-enter your password.")
                return
            }
        }

        isLoading = true
        Task {
            do {
                let user: AppUser
                if isSignUp {
                    user = try await AuthService.shared.signUp(
                        name: fullName.trimmingCharacters(in: .whitespaces),
                        schoolId: schoolId.trimmingCharacters(in: .whitespaces),
                        email: cleanEmail,
                        password: password
                    )
                } else {
                    user = try await AuthService.shared.signIn(
                        email: cleanEmail,
                        password: password,
                        expectedRole: selectedRole
                    )
                }
                await MainActor.run {
                    isLoading = false
                    activeRole = user.role
                    isLoggedIn = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    show("Couldn't continue", AuthService.message(for: error))
                }
            }
        }
    }

    private func forgotPassword() {
        let cleanEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        if cleanEmail.isEmpty {
            show("Enter your email", "Type your Gmail above, then tap Forgot credentials.")
            return
        }
        Task {
            do {
                try await AuthService.shared.resetPassword(email: cleanEmail)
                await MainActor.run { show("Check your inbox", "We sent a password reset link to \(cleanEmail).") }
            } catch {
                await MainActor.run { show("Couldn't send email", AuthService.message(for: error)) }
            }
        }
    }

    private func show(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
