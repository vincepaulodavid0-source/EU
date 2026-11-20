import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct StaffAccount: Identifiable, Equatable {
    let id: String            
    var name: String
    var email: String
    var isActive: Bool

    var code: String {
        String(name.filter { $0.isLetter || $0.isNumber }.prefix(3)).uppercased()
    }
}

final class StaffService {
    static let shared = StaffService()
    private let db = Firestore.firestore()

    func loadStaff() async throws -> [StaffAccount] {
        let snap = try await db.collection("users")
            .whereField("role", isEqualTo: "Staff")
            .getDocuments()
        return snap.documents.map { doc in
            let d = doc.data()
            return StaffAccount(
                id: doc.documentID,
                name: d["name"] as? String ?? "",
                email: d["email"] as? String ?? "",
                isActive: d["isActive"] as? Bool ?? true
            )
        }
        .sorted { $0.name < $1.name }
    }

    
    func createStaff(name: String, email: String, password: String) async throws {
        let appName = "StaffCreator"
        if FirebaseApp.app(name: appName) == nil, let options = FirebaseApp.app()?.options {
            FirebaseApp.configure(name: appName, options: options)
        }
        guard let secondary = FirebaseApp.app(name: appName) else { return }
        let secondaryAuth = Auth.auth(app: secondary)

        let result = try await secondaryAuth.createUser(withEmail: email, password: password)
        try? secondaryAuth.signOut()

  
        try await db.collection("users").document(result.user.uid).setData([
            "name": name,
            "schoolId": "",
            "email": email,
            "role": "Staff",
            "isActive": true,
            "createdAt": Timestamp(date: Date())
        ])
    }

    func setActive(uid: String, _ isActive: Bool) async throws {
        try await db.collection("users").document(uid).updateData(["isActive": isActive])
    }
}
