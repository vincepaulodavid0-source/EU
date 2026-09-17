import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    @State private var pushNotificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 16) {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack {
                                if let profileImage = profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(red: 0.6, green: 0, blue: 0))
                                }
                                
                                Circle()
                                    .fill(Color(red: 0.6, green: 0, blue: 0))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 20, y: 20)
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedItem) {
                            Task {
                                if let newItem = selectedItem,
                                   let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vince Paulo David")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("ID: 24-00000")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("College of Computing and Multimedia Studies")
                                .font(.caption2)
                                .foregroundColor(Color(red: 0.6, green: 0, blue: 0))
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Toggle(isOn: $pushNotificationsEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Push Notification Match")
                                .fontWeight(.medium)
                            Text("Get notified immediately on matching items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(Color(red: 0.6, green: 0, blue: 0))
                    
                    Toggle(isOn: $darkModeEnabled) {
                        Text("Dark Mode")
                            .fontWeight(.medium)
                    }
                    .tint(Color(red: 0.6, green: 0, blue: 0))
                }
                
                Section {
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
