import SwiftUI

struct ClaimTicketDetailView: View {
    @Binding var claim: ClaimItemModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ITEM NAME")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(claim.itemTitle)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("STATUS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Text(claim.status)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.6, green: 0, blue: 0))
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
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Claim Progress")
                        .font(.headline)
                    
                    HStack(spacing: 0) {
                        ProgressStep(title: "Submitted", isCompleted: true, isCurrent: claim.status == "Submitted")
                        ProgressLine(isCompleted: true)
                        ProgressStep(title: "Approved", isCompleted: claim.status == "Approved" || claim.status == "Handed Over", isCurrent: claim.status == "Pending Verification")
                        ProgressLine(isCompleted: claim.status == "Handed Over")
                        ProgressStep(title: "Handed Over", isCompleted: claim.status == "Handed Over", isCurrent: false)
                    }
                    .padding(.vertical, 8)
                }
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
                    .fill(isCompleted ? Color(red: 0.6, green: 0, blue: 0) : Color(.systemGray4))
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
            .fill(isCompleted ? Color(red: 0.6, green: 0, blue: 0) : Color(.systemGray4))
            .frame(height: 3)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, -4)
            .offset(y: -10)
    }
}
