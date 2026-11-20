import Foundation
import FirebaseFirestore

struct ClaimItemModel: Identifiable, Equatable {
    let id: UUID
    let itemTitle: String
    let ticketNumber: String
    var status: String          
    let createdAt: Date
    var handedOverAt: Date?
    var itemID: UUID?
    var category: String
    var location: String
    var imageURL: String?
    var studentName: String
    var studentID: String
    var studentUID: String
    var proofDescription: String

   
    var isActive: Bool { status == "Pending Verification" || status == "Approved" }

 
    var dateSubmitted: String {
        createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    init(id: UUID = UUID(),
         itemTitle: String,
         ticketNumber: String? = nil,
         status: String = "Pending Verification",
         createdAt: Date = Date(),
         handedOverAt: Date? = nil,
         itemID: UUID? = nil,
         category: String = "Others",
         location: String = "",
         imageURL: String? = nil,
         studentName: String,
         studentID: String,
         studentUID: String,
         proofDescription: String = "") {
        self.id = id
        self.itemTitle = itemTitle
       
        self.ticketNumber = ticketNumber ?? ("#" + String(id.uuidString.prefix(6)))
        self.status = status
        self.createdAt = createdAt
        self.handedOverAt = handedOverAt
        self.itemID = itemID
        self.category = category
        self.location = location
        self.imageURL = imageURL
        self.studentName = studentName
        self.studentID = studentID
        self.studentUID = studentUID
        self.proofDescription = proofDescription
    }

    init?(doc: QueryDocumentSnapshot) {
        let d = doc.data()
        guard let id = UUID(uuidString: doc.documentID) else { return nil }
        self.init(
            id: id,
            itemTitle: d["itemTitle"] as? String ?? "Item",
            ticketNumber: d["ticketNumber"] as? String,
            status: d["status"] as? String ?? "Pending Verification",
            createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            handedOverAt: (d["handedOverAt"] as? Timestamp)?.dateValue(),
            itemID: (d["itemID"] as? String).flatMap { UUID(uuidString: $0) },
            category: d["category"] as? String ?? "Others",
            location: d["location"] as? String ?? "",
            imageURL: d["imageURL"] as? String,
            studentName: d["studentName"] as? String ?? "",
            studentID: d["studentID"] as? String ?? "",
            studentUID: d["studentUID"] as? String ?? "",
            proofDescription: d["proofDescription"] as? String ?? ""
        )
    }

    var data: [String: Any] {
        var d: [String: Any] = [
            "itemTitle": itemTitle,
            "ticketNumber": ticketNumber,
            "status": status,
            "createdAt": Timestamp(date: createdAt),
            "category": category,
            "location": location,
            "studentName": studentName,
            "studentID": studentID,
            "studentUID": studentUID,
            "proofDescription": proofDescription
        ]
        if let itemID { d["itemID"] = itemID.uuidString }
        if let imageURL { d["imageURL"] = imageURL }
        if let handedOverAt { d["handedOverAt"] = Timestamp(date: handedOverAt) }
        return d
    }
}
