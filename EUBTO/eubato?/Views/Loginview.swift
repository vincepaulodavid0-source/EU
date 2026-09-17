import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    
    @State private var selectedRole = "Student"
    @State private var schoolId = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let roles = ["Student", "Admin", "Staff"]
    let customRed = Color(red: 0.6, green: 0, blue: 0)

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
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
                Picker("Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("School id")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        TextField("e.g., A24-0000", text: $schoolId)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack {
                            if showPassword {
                                TextField("••••••••••••", text: $password)
                            } else {
                                SecureField("••••••••••••", text: $password)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Text("Forgot credentials?")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(customRed)
                        }
                    }
                }
                .padding(.horizontal)
                
                
                Button(action: {
                    if selectedRole == "Student" {
                        isLoggedIn = true
                    } else {
                        alertMessage = "\(selectedRole) portal is under development and not available yet. Please log in as a Student."
                        showAlert = true
                    }
                }) {
                    Text("Log In")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customRed)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Access Restricted"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}
