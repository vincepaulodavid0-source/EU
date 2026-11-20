import SwiftUI

struct ClaimsView: View {
    @Binding var userClaims: [ClaimItemModel]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Claim Tickets")) {
                    if !userClaims.contains(where: { $0.isActive }) {
                        Text("No active claims.")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    ForEach($userClaims) { $claim in
                        if claim.isActive { row($claim) }
                    }
                }

                if userClaims.contains(where: { !$0.isActive }) {
                    Section(header: Text("History")) {
                        ForEach($userClaims) { $claim in
                            if !claim.isActive { row($claim) }
                        }
                    }
                }
            }
            .navigationTitle("Claim Status")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func row(_ claim: Binding<ClaimItemModel>) -> some View {
        NavigationLink(destination: ClaimTicketDetailView(claim: claim)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(claim.wrappedValue.itemTitle).font(.headline)
                    StatusPill(text: claim.wrappedValue.status)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(claim.wrappedValue.ticketNumber)
                        .font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                    Text(claim.wrappedValue.dateSubmitted)
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
