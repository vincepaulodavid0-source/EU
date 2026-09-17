import SwiftUI

struct ItemDetailView: View {
    @Binding var item: ItemModel
    @Binding var userClaims: [ClaimItemModel]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Enlarged Photo View
                if let image = item.itemImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 300)
                        Image(systemName: "photo.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                    }
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text(item.status == "Pending Verification" ? "Pending" : "Unclaimed")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(item.status == "Pending Verification" ? Color.orange.opacity(0.2) : Color(.systemGray5))
                            .foregroundColor(item.status == "Pending Verification" ? .orange : .primary)
                            .cornerRadius(6)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(item.status == "Pending Verification" ? "Electronics" : item.status) // Adjust if category is stored separately
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Guard Station Surrendered")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(red: 0.6, green: 0, blue: 0))
                            Text(item.location)
                                .font(.body)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Found Location Description")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(item.details)
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                
                if item.status != "Pending Verification" {
                    Button(action: {
                        item.status = "Pending Verification"
                        let randomTicket = "#\(Int.random(in: 1000...9999))"
                        let newClaim = ClaimItemModel(
                            itemTitle: item.title,
                            ticketNumber: randomTicket,
                            status: "Pending Verification",
                            dateSubmitted: "Just now"
                        )
                        userClaims.insert(newClaim, at: 0)
                        dismiss()
                    }) {
                        Text("Claim This Item")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.6, green: 0, blue: 0))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
