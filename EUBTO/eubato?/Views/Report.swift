import SwiftUI
import PhotosUI

struct ReportView: View {
    @ObservedObject var controller: ItemController
    
    @State private var itemName = ""
    @State private var selectedCategory = "IDs & Cards"
    @State private var selectedGuardStation = "Guard Station 1 (Gate 1)"
    @State private var locationDescription = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    
    let customRed = Color(red: 0.6, green: 0, blue: 0)
    let categories = ["IDs & Cards", "Electronics", "Keys", "Others"]
    let guardStations = ["Guard Station 1 (Gate 1)", "Guard Station 2", "Main Library Desk"]

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
                            if let selectedImage = selectedImage {
                                selectedImage
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
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImg = UIImage(data: data) {
                                selectedImage = Image(uiImage: uiImg)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Item Name")
                                .font(.caption)
                                .fontWeight(.bold)
                            TextField("e.g., Black Umbrella", text: $itemName)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }

               
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category")
                                .font(.caption)
                                .fontWeight(.bold)
                            Menu {
                                ForEach(categories, id: \.self) { category in
                                    Button(category) { selectedCategory = category }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategory)
                                        .foregroundColor(customRed)
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
                        }

                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Guard Station Surrendered")
                                .font(.caption)
                                .fontWeight(.bold)
                            Menu {
                                ForEach(guardStations, id: \.self) { station in
                                    Button(station) { selectedGuardStation = station }
                                }
                            } label: {
                                HStack {
                                    Text(selectedGuardStation)
                                        .foregroundColor(customRed)
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
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Found Location Description")
                                .font(.caption)
                                .fontWeight(.bold)
                            TextField("e.g., Canteen, table infront of papa APS", text: $locationDescription)
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)

                    Button(action: {
                        let finalTitle = itemName.isEmpty ? "Unnamed Item" : itemName
                        let finalDetails = locationDescription.isEmpty ? "No description provided" : locationDescription
                        
                        let newItem = ItemModel(
                            title: finalTitle,
                            details: finalDetails,
                            location: selectedGuardStation,
                            status: selectedCategory, 
                            itemImage: selectedImage
                        )
                        
                       
                        controller.feedItems.insert(newItem, at: 0)
                        
                        
                        itemName = ""
                        locationDescription = ""
                        selectedImage = nil
                        selectedItem = nil
                    }) {
                        Text("Post to Feed")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(customRed)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}
