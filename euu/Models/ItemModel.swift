import Foundation
import FirebaseFirestore

struct ItemModel: Identifiable, Equatable {
    let id: UUID
    let title: String
    let details: String
    let location: String
    let category: String         
    var status: String           
    var imageURL: String?
    var createdAt: Date
    var reportedBy: String

    init(id: UUID = UUID(),
         title: String,
         details: String,
         location: String,
         category: String,
         status: String = "Unclaimed",
         imageURL: String? = nil,
         createdAt: Date = Date(),
         reportedBy: String = "") {
        self.id = id
        self.title = title
        self.details = details
        self.location = location
        self.category = category
        self.status = status
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.reportedBy = reportedBy
    }

 
    init?(doc: QueryDocumentSnapshot) {
        let d = doc.data()
        guard let id = UUID(uuidString: doc.documentID) else { return nil }
        self.init(
            id: id,
            title: d["title"] as? String ?? "Unnamed Item",
            details: d["details"] as? String ?? "",
            location: d["location"] as? String ?? "",
            category: d["category"] as? String ?? "Others",
            status: d["status"] as? String ?? "Unclaimed",
            imageURL: d["imageURL"] as? String,
            createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            reportedBy: d["reportedBy"] as? String ?? ""
        )
    }

    var data: [String: Any] {
        var d: [String: Any] = [
            "title": title,
            "details": details,
            "location": location,
            "category": category,
            "status": status,
            "createdAt": Timestamp(date: createdAt),
            "reportedBy": reportedBy
        ]
        if let imageURL { d["imageURL"] = imageURL }
        return d
    }
}
