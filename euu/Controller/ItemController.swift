import SwiftUI
import Combine
import FirebaseFirestore

enum ControllerError: LocalizedError {
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "You need to be logged in to do that."
        }
    }
}

@MainActor
final class ItemController: ObservableObject {
    @Published var feedItems: [ItemModel] = []
    @Published var claims: [ClaimItemModel] = []
    @Published private(set) var user: AppUser?
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var itemsListener: ListenerRegistration?
    private var claimsListener: ListenerRegistration?

    func start(user: AppUser) {
        stop()
        self.user = user

        itemsListener = db.collection("items")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                let items = snapshot?.documents.compactMap { ItemModel(doc: $0) }
                let message = error?.localizedDescription
                Task { @MainActor in
                    guard let self else { return }
                    if let items { self.feedItems = items }
                    if let message { self.errorMessage = message }
                }
            }

        let base = db.collection("claims")
        let query: Query = user.role == "Student"
            ? base.whereField("studentUID", isEqualTo: user.uid)
            : base
        claimsListener = query.addSnapshotListener { [weak self] snapshot, error in
            let list = snapshot?.documents
                .compactMap { ClaimItemModel(doc: $0) }
                .sorted { $0.createdAt > $1.createdAt }
            let message = error?.localizedDescription
            Task { @MainActor in
                guard let self else { return }
                if let list { self.claims = list }
                if let message { self.errorMessage = message }
            }
        }
    }

    func stop() {
        itemsListener?.remove()
        claimsListener?.remove()
        itemsListener = nil
        claimsListener = nil
        feedItems = []
        claims = []
        user = nil
    }

    func report(title: String, details: String, location: String,
                category: String, image: UIImage?) async throws {
        guard let user else { throw ControllerError.notSignedIn }
        let id = UUID()


        var url: String? = nil
        if let image, let data = Self.jpegData(from: image) {
            url = "data:image/jpeg;base64," + data.base64EncodedString()
        }

        let item = ItemModel(
            id: id,
            title: title.isEmpty ? "Unnamed Item" : title,
            details: details.isEmpty ? "No description provided" : details,
            location: location,
            category: category,
            imageURL: url,
            reportedBy: user.uid
        )
        try await db.collection("items").document(id.uuidString).setData(item.data)
    }


    func submitClaim(for item: ItemModel, proof: String) async throws {
        guard let user else { throw ControllerError.notSignedIn }

        let claimID = UUID()
        let studentName = user.name
        let studentID = user.schoolId
        let studentUID = user.uid
        let itemRef = db.collection("items").document(item.id.uuidString)
        let claimRef = db.collection("claims").document(claimID.uuidString)
        let counterRef = db.collection("counters").document("claims")

        _ = try await db.runTransaction { transaction, errorPointer -> Any? in
            let itemSnap: DocumentSnapshot
            let counterSnap: DocumentSnapshot
            do {
                itemSnap = try transaction.getDocument(itemRef)
                counterSnap = try transaction.getDocument(counterRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            guard (itemSnap.data()?["status"] as? String) == "Unclaimed" else {
                errorPointer?.pointee = NSError(
                    domain: "EUbaTo", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Someone already claimed this item."])
                return nil
            }

           
            let next = counterSnap.data()?["next"] as? Int ?? 1001
            let claim = ClaimItemModel(
                id: claimID,
                itemTitle: item.title,
                ticketNumber: "#\(next)",
                itemID: item.id,
                category: item.category,
                location: item.location,
                imageURL: item.imageURL,
                studentName: studentName,
                studentID: studentID,
                studentUID: studentUID,
                proofDescription: proof
            )
            transaction.setData(claim.data, forDocument: claimRef)
            transaction.setData(["next": next + 1], forDocument: counterRef)
            transaction.updateData(["status": "Pending Verification"], forDocument: itemRef)
            return nil
        }
    }


    func setClaimStatus(_ claim: ClaimItemModel, to newStatus: String) {
        Task {
            do {
                let batch = db.batch()
                var claimUpdate: [String: Any] = [
                    "status": newStatus,
                    "reviewedBy": user?.uid ?? ""
                ]
                if newStatus == "Handed Over" {
                    claimUpdate["handedOverAt"] = Timestamp(date: Date())
                }
                batch.updateData(claimUpdate,
                                 forDocument: db.collection("claims").document(claim.id.uuidString))

                if let itemID = claim.itemID {
                    let itemStatus: String?
                    switch newStatus {
                    case "Rejected":    itemStatus = "Unclaimed"   
                    case "Approved":    itemStatus = "Approved"
                    case "Handed Over": itemStatus = "Handed Over"
                    default:            itemStatus = nil
                    }
                    if let itemStatus {
                        batch.updateData(["status": itemStatus],
                                         forDocument: db.collection("items").document(itemID.uuidString))
                    }
                }
                try await batch.commit()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }


    func state(of item: ItemModel) -> String {
        switch item.status {
        case "Handed Over": return "Claimed"
        case "Pending Verification", "Approved": return "Pending"
        default: return "Unclaimed"
        }
    }

    func claim(for item: ItemModel) -> ClaimItemModel? {
        claims.first { $0.itemID == item.id }
    }

    var queueClaims: [ClaimItemModel] {
        claims.filter { $0.status == "Pending Verification" || $0.status == "Approved" }
    }
    var pendingCount: Int { claims.filter { $0.status == "Pending Verification" }.count }
    var inCustodyCount: Int { feedItems.filter { state(of: $0) != "Claimed" }.count }

    var handoverCount: Int {
        claims.filter {
            $0.status == "Handed Over" &&
            ($0.handedOverAt.map { Calendar.current.isDateInToday($0) } ?? false)
        }.count
    }

    private static func jpegData(from image: UIImage, maxSide: CGFloat = 500) -> Data? {
        let longest = max(image.size.width, image.size.height)
        let scale = min(1, maxSide / longest)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.5)
    }
}
