import SwiftUI

struct StaffTabView: View {
    @Binding var isLoggedIn: Bool
    @ObservedObject var controller: ItemController
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            StaffDashboardView(controller: controller, selection: $selection)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }.tag(0)

            InventoryListView(controller: controller, title: "Inventory")
                .tabItem { Label("Inventory", systemImage: "archivebox") }.tag(1)

            StaffVerificationView(controller: controller)
                .tabItem { Label("Staff", systemImage: "checkmark.shield") }.tag(2)

            PortalMenuView(isLoggedIn: $isLoggedIn,
                           displayName: controller.user?.name ?? "Staff")
                .tabItem { Label("Menu", systemImage: "line.3.horizontal") }.tag(3)
        }
        .tint(.brandRed)
    }
}


struct StaffDashboardView: View {
    @ObservedObject var controller: ItemController
    @Binding var selection: Int

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 12 ? "Good morning," : (hour < 18 ? "Good afternoon," : "Good evening,")
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greeting).font(.caption).foregroundColor(.secondary)
                        Text(controller.user?.name ?? "Staff").font(.title3).fontWeight(.bold)
                    }

                    Button { selection = 2 } label: {
                        StatCard(title: "Pending Claims", value: controller.pendingCount,
                                 icon: "questionmark.circle", showChevron: true)
                    }.buttonStyle(.plain)

                    Button { selection = 1 } label: {
                        StatCard(title: "Items in Storage", value: controller.inCustodyCount,
                                 icon: "archivebox", showChevron: true)
                    }.buttonStyle(.plain)

                    
                    StatCard(title: "Today's Handovers", value: controller.handoverCount,
                             icon: "checkmark.circle")

                    Text("Recent Activity").font(.headline).padding(.top, 6)

                    if controller.claims.isEmpty {
                        Text("No activity yet.").font(.subheadline).foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(controller.claims.prefix(5)) { claim in
                                HStack(spacing: 10) {
                                    Circle().fill(statusColor(claim.status)).frame(width: 8, height: 8)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(claim.itemTitle).font(.caption).fontWeight(.semibold)
                                        Text("Claimer: \(claim.studentName)").font(.caption2).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(claim.dateSubmitted).font(.caption2).foregroundColor(.secondary)
                                }
                                .padding(12)
                                Divider()
                            }
                        }
                        .background(Color(.systemBackground)).cornerRadius(10)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("EU ba'to?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct StaffVerificationView: View {
    @ObservedObject var controller: ItemController
    @State private var receiptClaim: ClaimItemModel?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Text("\(controller.pendingCount) Pending")
                            .font(.caption2).fontWeight(.bold)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.brandRed.opacity(0.12)).foregroundColor(.brandRed).cornerRadius(4)
                        Text("verifications require approval").font(.caption2).foregroundColor(.secondary)
                    }

                    if controller.queueClaims.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray").font(.largeTitle).foregroundColor(.secondary)
                            Text("Nothing to verify").font(.subheadline).foregroundColor(.secondary)
                        }.frame(maxWidth: .infinity).padding(.top, 60)
                    }

                    ForEach(controller.queueClaims) { claim in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(claim.studentName).font(.subheadline).fontWeight(.bold)
                            Text("Student ID: \(claim.studentID)").font(.caption2).foregroundColor(.secondary)

                            VStack(spacing: 6) {
                                HStack {
                                    Text("Claiming Item").font(.caption2).foregroundColor(.secondary)
                                    Spacer()
                                    Text(claim.itemTitle).font(.caption).fontWeight(.semibold)
                                }
                                HStack {
                                    Text("Submitted").font(.caption2).foregroundColor(.secondary)
                                    Spacer()
                                    Text(claim.dateSubmitted).font(.caption)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Owner's description").font(.caption2).foregroundColor(.secondary)
                                    Text(claim.proofDescription.isEmpty ? "—" : claim.proofDescription)
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(10).background(Color(.systemGray6)).cornerRadius(8)

                            HStack(spacing: 8) {
                                Button("View Receipt") { receiptClaim = claim }
                                    .font(.caption).fontWeight(.semibold).foregroundColor(.brandRed)
                                Spacer()
                                if claim.status == "Pending Verification" {
                                    Button("Reject") { controller.setClaimStatus(claim, to: "Rejected") }
                                        .font(.caption).fontWeight(.semibold).foregroundColor(.brandRed)
                                        .padding(.horizontal, 14).padding(.vertical, 6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.brandRed))
                                    Button("Approve") { controller.setClaimStatus(claim, to: "Approved") }
                                        .font(.caption).fontWeight(.semibold).foregroundColor(.white)
                                        .padding(.horizontal, 14).padding(.vertical, 6)
                                        .background(Color.green).cornerRadius(6)
                                } else {
                                    StatusPill(text: "Approved")
                                    Button("Mark Handed Over") { controller.setClaimStatus(claim, to: "Handed Over") }
                                        .font(.caption).fontWeight(.semibold).foregroundColor(.white)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Color.brandRed).cornerRadius(6)
                                }
                            }
                        }
                        .padding(14).background(Color(.systemBackground)).cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Verification Queue")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $receiptClaim) { ReceiptView(claim: $0) }
        }
    }
}
