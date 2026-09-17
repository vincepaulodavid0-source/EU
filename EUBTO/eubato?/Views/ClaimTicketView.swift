import SwiftUI

struct ClaimTicketView: View {
    @Binding var userClaims: [ClaimItemModel]
    @State private var selectedClaim: ClaimItemModel? = nil
    @State private var showDetailSheet = false
    
    let customRed = Color(red: 0.6, green: 0, blue: 0)

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                if userClaims.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Claim Tickets Yet")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Items you claim from the feed will generate tracking tickets here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach($userClaims) { $claim in
                            Button(action: {
                                selectedClaim = claim
                                showDetailSheet = true
                            }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(customRed.opacity(0.1))
                                            .frame(width: 55, height: 55)
                                        Image(systemName: "ticket.fill")
                                            .foregroundColor(customRed)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(claim.ticketNumber)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            Spacer()
                                            Text(claim.status)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.orange.opacity(0.2))
                                                .foregroundColor(.orange)
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(claim.itemTitle)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Submitted: \(claim.dateSubmitted)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Claim Tickets")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDetailSheet) {
                if let claim = selectedClaim,
                   let index = userClaims.firstIndex(where: { $0.id == claim.id }) {
                    NavigationView {
                        ClaimTicketDetailView(claim: $userClaims[index])
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        showDetailSheet = false
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}
