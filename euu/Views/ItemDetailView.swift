import SwiftUI

struct ItemDetailView: View {
    let item: ItemModel
    @ObservedObject var controller: ItemController
    @Environment(\.dismiss) var dismiss

    @State private var showClaimAlert = false
    @State private var proof = ""
    @State private var isSubmitting = false

    private let customRed = Color(red: 0.6, green: 0, blue: 0)

    // Always read the live copy so the screen updates if someone else claims it.
    private var live: ItemModel {
        controller.feedItems.first { $0.id == item.id } ?? item
    }
    private var isUnclaimed: Bool { live.status == "Unclaimed" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RemoteImage(url: live.imageURL)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(live.title).font(.title2).fontWeight(.bold)
                        Spacer()
                        Text(isUnclaimed ? "Unclaimed" : "Pending")
                            .font(.subheadline).fontWeight(.bold)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(isUnclaimed ? Color(.systemGray5) : Color.orange.opacity(0.2))
                            .foregroundColor(isUnclaimed ? .primary : .orange)
                            .cornerRadius(6)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category").font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                        Text(live.category).font(.body).fontWeight(.medium)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Guard Station Surrendered")
                            .font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "mappin.and.ellipse").foregroundColor(customRed)
                            Text(live.location).font(.body)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Found Location Description")
                            .font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                        Text(live.details).font(.body)
                    }
                }
                .padding(.horizontal)

                if isUnclaimed {
                    Button { showClaimAlert = true } label: {
                        ZStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text("Claim This Item").font(.headline).fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customRed.opacity(isSubmitting ? 0.6 : 1))
                        .cornerRadius(8)
                    }
                    .disabled(isSubmitting)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Prove it's yours", isPresented: $showClaimAlert) {
            TextField("Describe something only the owner knows", text: $proof)
            Button("Submit Claim") { submit() }
            Button("Cancel", role: .cancel) { proof = "" }
        } message: {
            Text("Staff will compare your description with the item before approving.")
        }
    }

    @MainActor
    private func submit() {
        let text = proof.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            controller.errorMessage = "Describe something only the owner would know (color, marks, contents...)."
            return
        }
        isSubmitting = true
        Task {
            do {
                try await controller.submitClaim(for: live, proof: text)
                proof = ""
                dismiss()
            } catch {
                controller.errorMessage = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
