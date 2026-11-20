import SwiftUI
import PhotosUI

struct ReportView: View {
    @ObservedObject var controller: ItemController

    @State private var itemName = ""
    @State private var selectedCategory = "IDs & Cards"
    @State private var selectedGuardStation = Stations.all[0]
    @State private var locationDescription = ""

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var isPosting = false
    @State private var showPosted = false

    let customRed = Color(red: 0.6, green: 0, blue: 0)
    let categories = ["IDs & Cards", "Electronics", "Keys", "Others"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Snap & Report")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack(alignment: .center) {
                            if let ui = selectedUIImage {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .background(Color(.systemGray6))
                                    .frame(height: 180)

                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.gray)
                                    Text("Tap to snap or upload photo")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let ui = UIImage(data: data) {
                                selectedUIImage = ui
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Item Name").font(.caption).fontWeight(.bold)
                            TextField("e.g., Black Umbrella", text: $itemName)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category").font(.caption).fontWeight(.bold)
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(category) { selectedCategory = category }
                                }
                            } label: {
                                menuLabel(selectedCategory)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Guard Station Surrendered").font(.caption).fontWeight(.bold)
                            Menu {
                                ForEach(Stations.all, id: \.self) { station in
                                    Button(station) { selectedGuardStation = station }
                                }
                            } label: {
                                menuLabel(selectedGuardStation)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Found Location Description").font(.caption).fontWeight(.bold)
                            TextField("e.g., Canteen, table infront of papa APS", text: $locationDescription)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)

                    Button(action: post) {
                        ZStack {
                            if isPosting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Post to Feed").font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customRed.opacity(isPosting ? 0.6 : 1))
                        .cornerRadius(8)
                    }
                    .disabled(isPosting)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .alert("Posted!", isPresented: $showPosted) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your report is now on the feed.")
            }
        }
    }

    private func menuLabel(_ text: String) -> some View {
        HStack {
            Text(text).foregroundColor(customRed)
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundColor(customRed)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }

    @MainActor
    private func post() {
        isPosting = true
        Task {
            do {
                try await controller.report(
                    title: itemName.trimmingCharacters(in: .whitespaces),
                    details: locationDescription.trimmingCharacters(in: .whitespaces),
                    location: selectedGuardStation,
                    category: selectedCategory,
                    image: selectedUIImage
                )
                itemName = ""
                locationDescription = ""
                selectedUIImage = nil
                selectedItem = nil
                showPosted = true
            } catch {
                controller.errorMessage = error.localizedDescription
            }
            isPosting = false
        }
    }
}
