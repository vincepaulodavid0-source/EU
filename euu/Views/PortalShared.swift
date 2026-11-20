import SwiftUI

extension Color {
    static let brandRed = Color(red: 0.6, green: 0, blue: 0)
}


enum Stations {
    static let all = [
        "Guard Station 1 (Gate 1)",
        "Guard Station 2 (Gate 2)",
        "Guard Station 3 (Gate 3)",
        "Main Library Desk"
    ]
}

func statusColor(_ s: String) -> Color {
    switch s {
    case "Claimed", "Handed Over", "Approved": return .green
    case "Pending", "Pending Verification":    return .orange
    case "Rejected":                           return .red
    default:                                   return .gray
    }
}

struct StatusPill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2).fontWeight(.bold)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(statusColor(text).opacity(0.15))
            .foregroundColor(statusColor(text))
            .cornerRadius(4)
    }
}

struct ItemThumb: View {
    let url: String?
    var size: CGFloat = 55
    var body: some View {
        RemoteImage(url: url)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    var icon: String? = nil
    var showChevron = false
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.brandRed)
                    .frame(width: 36, height: 36)
                    .background(Color.brandRed.opacity(0.1))
                    .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text("\(value)").font(.title3).fontWeight(.bold).foregroundColor(icon == nil ? .brandRed : .primary)
            }
            Spacer()
            if showChevron { Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary) }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct ReceiptView: View {
    let claim: ClaimItemModel
    @Environment(\.dismiss) var dismiss

    var receiptNo: String { "#RF-2026-\(claim.ticketNumber.replacingOccurrences(of: "#", with: ""))" }

    func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.caption).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.caption).fontWeight(.semibold)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.title).foregroundColor(.brandRed)
                        Text("Claim Receipt").font(.headline)
                        Divider()
                        row("Receipt No", receiptNo)
                        row("Student Name", claim.studentName)
                        row("Student ID", claim.studentID)
                        row("Item Claimed", claim.itemTitle)
                        row("Category", claim.category)
                        row("Location Found", claim.location.isEmpty ? "—" : claim.location)
                        row("Date Claimed", claim.dateSubmitted)
                        HStack {
                            Text("Status").font(.caption).foregroundColor(.secondary)
                            Spacer()
                            StatusPill(text: claim.status)
                        }
                    }
                    .padding().background(Color(.systemBackground)).cornerRadius(12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("OWNER'S DESCRIPTION (PROOF)")
                            .font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        Text(claim.proofDescription.isEmpty ? "—" : claim.proofDescription)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding().background(Color(.systemBackground)).cornerRadius(12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PHOTO OF ITEM")
                            .font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        RemoteImage(url: claim.imageURL)
                            .frame(height: 160).frame(maxWidth: .infinity)
                            .clipped().cornerRadius(8)
                    }
                    .padding().background(Color(.systemBackground)).cornerRadius(12)

                    Button("Close") { dismiss() }.foregroundColor(.secondary).padding(.top, 4)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InventoryListView: View {
    @ObservedObject var controller: ItemController
    var title = "Inventory"
    var subtitle: String? = nil
    var showFilters = true

    @State private var search = ""
    @State private var filter = "All"
    @State private var receiptClaim: ClaimItemModel?
    let filters = ["All", "Unclaimed", "Claimed", "Pending"]

    var items: [ItemModel] {
        controller.feedItems.filter { item in
            let matchesFilter = filter == "All" || controller.state(of: item) == filter
            let matchesSearch = search.isEmpty
                || item.title.localizedCaseInsensitiveContains(search)
                || item.location.localizedCaseInsensitiveContains(search)
                || item.details.localizedCaseInsensitiveContains(search)
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search locker ID, categories, items...", text: $search)
                }
                .padding(10).background(Color(.systemGray6)).cornerRadius(10).padding(.horizontal)

                if showFilters {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filters, id: \.self) { f in
                                Button { filter = f } label: {
                                    Text(f).font(.caption).fontWeight(.medium)
                                        .padding(.horizontal, 14).padding(.vertical, 6)
                                        .background(filter == f ? Color.brandRed : Color(.systemGray6))
                                        .foregroundColor(filter == f ? .white : .primary)
                                        .cornerRadius(16)
                                }
                            }
                        }.padding(.horizontal)
                    }
                }

                if items.isEmpty {
                    Spacer()
                    Text("No items found.").foregroundColor(.secondary).frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(items) { item in
                                let state = controller.state(of: item)
                                let claim = controller.claim(for: item)
                                HStack(spacing: 12) {
                                    ItemThumb(url: item.imageURL)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.title).font(.subheadline).fontWeight(.bold)
                                            Spacer()
                                            StatusPill(text: state)
                                        }
                                        Text(item.location).font(.caption2).foregroundColor(.secondary)
                                        if let claim = claim {
                                            Button("View Receipt") { receiptClaim = claim }
                                                .font(.caption2).fontWeight(.semibold).foregroundColor(.brandRed)
                                        }
                                    }
                                }
                                .padding(12).background(Color(.systemBackground)).cornerRadius(10)
                                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                            }
                        }.padding(.horizontal)
                    }
                }
            }
            .padding(.top, 8)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $receiptClaim) { ReceiptView(claim: $0) }
        }
    }
}


struct PortalMenuView: View {
    @Binding var isLoggedIn: Bool
    let displayName: String
    var nameColor: Color = .primary

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle")
                            .resizable().frame(width: 44, height: 44).foregroundColor(.secondary)
                        Text(displayName).font(.subheadline).fontWeight(.semibold).foregroundColor(nameColor)
                    }.padding(.vertical, 6)
                }
                Section {
                    Button { isLoggedIn = false } label: {
                        Text("Log Out").fontWeight(.bold).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 6)
                    }
                    .listRowBackground(Color.brandRed)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
