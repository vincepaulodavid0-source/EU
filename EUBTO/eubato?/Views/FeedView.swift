import SwiftUI

struct FeedView: View {
    @Binding var feedItems: [ItemModel]
    @Binding var userClaims: [ClaimItemModel]
    
    @State private var searchText = ""
    @State private var selectedCategory = "IDs & Cards"
    
    let categories = ["IDs & Cards", "Electronics", "Keys", "Others"]
    
    var filteredItems: [ItemModel] {
        feedItems.filter { item in
            
            let matchesCategory = item.status == selectedCategory || selectedCategory == "All"
            
            
            let matchesSearch = searchText.isEmpty ||
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.location.localizedCaseInsensitiveContains(searchText) ||
                item.details.localizedCaseInsensitiveContains(searchText)
            
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search found items, IDs, keywords...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color(red: 0.6, green: 0, blue: 0) : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List {
                
                    ForEach($feedItems.filter { item in
                        let matchesCategory = item.wrappedValue.status == selectedCategory
                        let matchesSearch = searchText.isEmpty ||
                            item.wrappedValue.title.localizedCaseInsensitiveContains(searchText) ||
                            item.wrappedValue.location.localizedCaseInsensitiveContains(searchText)
                        return matchesCategory && matchesSearch
                    }) { $item in
                        NavigationLink(destination: ItemDetailView(item: $item, userClaims: $userClaims)) {
                            HStack(spacing: 12) {
                                if let image = item.itemImage {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 55, height: 55)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color(.systemGray5))
                                            .frame(width: 55, height: 55)
                                            .cornerRadius(8)
                                        Image(systemName: "photo.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Spacer()
                                        Text(item.status)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(4)
                                    }
                                    
                                    Text(item.details)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.caption2)
                                        Text(item.location)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Campus Ledger")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
