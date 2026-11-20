import SwiftUI

struct AdminTabView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var controller: ItemController
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            AdminDashboardView(controller: controller)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }.tag(0)

            InventoryListView(controller: controller, title: "Inventory", showFilters: false)
                .tabItem { Label("Inventory", systemImage: "archivebox") }.tag(1)

            StaffControlView()
                .tabItem { Label("Staff", systemImage: "person.2") }.tag(2)

            PortalMenuView(isLoggedIn: $isLoggedIn,
                           displayName: controller.user?.name ?? "Admin",
                           nameColor: .brandRed)
                .tabItem { Label("Menu", systemImage: "gearshape") }.tag(3)
        }
        .tint(.brandRed)
    }
}


struct AdminDashboardView: View {
    @ObservedObject var controller: ItemController
    @State private var reviewID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("EU ba'to?").font(.headline).foregroundColor(.white)
                Spacer()
                Text("ADMIN").font(.caption2).fontWeight(.bold).foregroundColor(.brandRed)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.white).cornerRadius(10)
            }
            .padding().background(Color.brandRed)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        StatCard(title: "Pending Claims", value: controller.pendingCount)
                        StatCard(title: "In Custody", value: controller.inCustodyCount)
                    }
                    Text("Active Handover Queue").font(.caption).fontWeight(.bold).foregroundColor(.secondary)

                    if controller.queueClaims.isEmpty {
                        Text("No active handovers.").font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity).padding(.top, 30)
                    }
                    ForEach(controller.queueClaims) { claim in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(claim.studentName).font(.subheadline).fontWeight(.bold)
                                Text(claim.itemTitle).font(.caption2).foregroundColor(.secondary)
                                StatusPill(text: claim.status == "Approved" ? "Approved" : "Pending Review")
                            }
                            Spacer()
                            Button("Review") { reviewID = claim.id }
                                .font(.caption).fontWeight(.semibold).foregroundColor(.brandRed)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.brandRed))
                        }
                        .padding(12).background(Color(.systemBackground)).cornerRadius(10)
                        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(item: Binding(get: { reviewID.map { IDBox(id: $0) } }, set: { reviewID = $0?.id })) { box in
            AdminClaimTicketView(controller: controller, claimID: box.id)
        }
    }
}

struct IDBox: Identifiable { let id: UUID }


struct AdminClaimTicketView: View {
    @ObservedObject var controller: ItemController
    let claimID: UUID
    @Environment(\.dismiss) var dismiss

    var claim: ClaimItemModel? { controller.claims.first { $0.id == claimID } }

    func field(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2).foregroundColor(.secondary)
            Text(value).font(.subheadline).fontWeight(.semibold)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                if let claim = claim {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 12) {
                            field("ITEM NAME", claim.itemTitle)
                            StatusPill(text: claim.status)
                            HStack {
                                field("SUBMITTED", claim.dateSubmitted)
                                Spacer()
                                field("CATEGORY", claim.category)
                            }
                            Text("PHOTO OF ITEM").font(.caption2).foregroundColor(.secondary)
                            RemoteImage(url: claim.imageURL)
                                .frame(height: 160).frame(maxWidth: .infinity)
                                .clipped().cornerRadius(8)
                            field("CLAIMER NAME", claim.studentName)
                            field("STUDENT ID", claim.studentID)
                            field("OWNER'S DESCRIPTION", claim.proofDescription.isEmpty ? "—" : claim.proofDescription)
                            field("STATION SURRENDERED AT", claim.location.isEmpty ? "—" : claim.location)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding().background(Color(.systemBackground)).cornerRadius(12)

                        if claim.status == "Pending Verification" {
                            HStack(spacing: 10) {
                                Button("Reject") { controller.setClaimStatus(claim, to: "Rejected"); dismiss() }
                                    .fontWeight(.semibold).foregroundColor(.brandRed)
                                    .frame(maxWidth: .infinity).padding()
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandRed))
                                Button("Approve") { controller.setClaimStatus(claim, to: "Approved"); dismiss() }
                                    .fontWeight(.semibold).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding()
                                    .background(Color.brandRed).cornerRadius(8)
                            }
                        } else if claim.status == "Approved" {
                            Button("Mark Handed Over") { controller.setClaimStatus(claim, to: "Handed Over"); dismiss() }
                                .fontWeight(.semibold).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(Color.brandRed).cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Claim Ticket \(claim?.ticketNumber ?? "")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
