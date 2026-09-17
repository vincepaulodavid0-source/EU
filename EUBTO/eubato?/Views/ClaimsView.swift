import SwiftUI

struct ClaimsView: View {
    @Binding var userClaims: [ClaimItemModel]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Claim Tickets")) {
                    if userClaims.isEmpty {
                        Text("No active claims submitted yet.")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach($userClaims) { $claim in
                            NavigationLink(destination: ClaimTicketDetailView(claim: $claim)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(claim.itemTitle)
                                            .font(.headline)
                                        Text("Status: \(claim.status)")
                                            .font(.subheadline)
                                            .foregroundColor(Color(red: 0.6, green: 0, blue: 0))
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(claim.ticketNumber)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(6)
                                        Text(claim.dateSubmitted)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Claim Status")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
