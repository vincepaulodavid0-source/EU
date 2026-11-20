import SwiftUI

struct ClaimTicketDetailView: View {
    @Binding var claim: ClaimItemModel

    private var approved: Bool { claim.status == "Approved" || claim.status == "Handed Over" }
    private var handedOver: Bool { claim.status == "Handed Over" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ITEM NAME")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text(claim.itemTitle)
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STATUS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            StatusPill(text: claim.status)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("DATE SUBMITTED")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(claim.dateSubmitted)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("YOUR DESCRIPTION")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Text(claim.proofDescription.isEmpty ? "—" : claim.proofDescription)
                            .font(.subheadline)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Claim Progress")
                        .font(.headline)

                    if claim.status == "Rejected" {
                        Label("This claim was rejected. The item is back in the feed.",
                              systemImage: "xmark.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    } else {
                        HStack(spacing: 0) {
                            ProgressStep(title: "Submitted", isCompleted: true,
                                         isCurrent: claim.status == "Pending Verification")
                            ProgressLine(isCompleted: approved)
                            ProgressStep(title: "Approved", isCompleted: approved,
                                         isCurrent: claim.status == "Approved")
                            ProgressLine(isCompleted: handedOver)
                            ProgressStep(title: "Handed Over", isCompleted: handedOver, isCurrent: false)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Claim Ticket \(claim.ticketNumber)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressStep: View {
    let title: String
    let isCompleted: Bool
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.brandRed : Color(.systemGray4))
                    .frame(width: 28, height: 28)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            Text(title)
                .font(.caption2)
                .foregroundColor(isCompleted || isCurrent ? .primary : .secondary)
        }
    }
}

struct ProgressLine: View {
    let isCompleted: Bool

    var body: some View {
        Rectangle()
            .fill(isCompleted ? Color.brandRed : Color(.systemGray4))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, -4)
            .offset(y: -10)
    }
}
