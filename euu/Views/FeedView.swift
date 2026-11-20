import SwiftUI

struct FeedView: View {
    @ObservedObject var controller: ItemController

    @State private var searchText = ""
    @State private var selectedCategory = "IDs & Cards"

    let categories = ["IDs & Cards", "Electronics", "Keys", "Others"]
    private let customRed = Color(red: 0.6, green: 0, blue: 0)

    // Only items nobody has claimed yet appear in the feed.
    var filteredItems: [ItemModel] {
        controller.feedItems.filter { item in
            guard item.status == "Unclaimed", item.category == selectedCategory else { return false }
            return searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                || item.location.localizedCaseInsensitiveContains(searchText)
                || item.details.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search found items, IDs, keywords...", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button { selectedCategory = category } label: {
                                Text(category)
                                    .font(.subheadline).fontWeight(.medium)
                                    .padding(.horizontal, 16).padding(.vertical, 8)
                                    .background(selectedCategory == category ? customRed : Color(.systemGray6))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if filteredItems.isEmpty {
                    Spacer()
                    Text("No items found.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List(filteredItems) { item in
                        NavigationLink(destination: ItemDetailView(item: item, controller: controller)) {
                            HStack(spacing: 12) {
                                RemoteImage(url: item.imageURL)
                                    .frame(width: 55, height: 55)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(item.title).font(.headline).fontWeight(.bold)
                                        Spacer()
                                        Text(item.category)
                                            .font(.caption2).fontWeight(.bold)
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color(.systemGray5))
                                            .cornerRadius(4)
                                    }
                                    Text(item.details).font(.caption).foregroundColor(.secondary)
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse").font(.caption2)
                                        Text(item.location).font(.caption2)
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("EU ba'to?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
