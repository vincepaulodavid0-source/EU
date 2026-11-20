import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var controller: ItemController

    @AppStorage("darkMode") private var darkModeEnabled = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil   // local only for now, not saved

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
                                        .foregroundColor(.brandRed)
                                }

                                Circle()
                                    .fill(Color.brandRed)
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
                            Text(controller.user?.name ?? "")
                                .font(.headline)
                                .fontWeight(.bold)

                            Text("ID: \(controller.user?.schoolId ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(controller.user?.email ?? "")
                                .font(.caption2)
                                .foregroundColor(.brandRed)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Toggle(isOn: $darkModeEnabled) {
                        Text("Dark Mode")
                            .fontWeight(.medium)
                    }
                    .tint(.brandRed)
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
