import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AppUser {
    let uid: String
    let name: String
    let schoolId: String
    let email: String
    let role: String
}

enum AuthFlowError: LocalizedError {
    case profileMissing
    case inactive
    case wrongRole(String)

    var errorDescription: String? {
        switch self {
        case .profileMissing:
            return "This account has no profile yet. Ask an admin to set it up."
        case .inactive:
            return "This account has been deactivated. Contact the admin."
        case .wrongRole(let actual):
            return "This account is a \(actual) account. Select \(actual) above to log in."
        }
    }
}

final class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()

  
    func signUp(name: String, schoolId: String, email: String, password: String) async throws -> AppUser {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let data: [String: Any] = [
            "name": name,
            "schoolId": schoolId,
            "email": email,
            "role": "Student",
            "isActive": true,
            "createdAt": FieldValue.serverTimestamp()
        ]
        do {
            try await db.collection("users").document(result.user.uid).setData(data)
        } catch {
            
            try? await result.user.delete()
            throw error
        }
        try? await result.user.sendEmailVerification()
        return AppUser(uid: result.user.uid, name: name, schoolId: schoolId, email: email, role: "Student")
    }


    func signIn(email: String, password: String, expectedRole: String) async throws -> AppUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        do {
            let user = try await loadProfile(uid: result.user.uid)
            if user.role != expectedRole { throw AuthFlowError.wrongRole(user.role) }
            return user
        } catch {
            try? Auth.auth().signOut()
            throw error
        }
    }

    func loadProfile(uid: String) async throws -> AppUser {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let d = doc.data() else { throw AuthFlowError.profileMissing }
        if (d["isActive"] as? Bool) == false { throw AuthFlowError.inactive }
        return AppUser(
            uid: uid,
            name: d["name"] as? String ?? "",
            schoolId: d["schoolId"] as? String ?? "",
            email: d["email"] as? String ?? "",
            role: d["role"] as? String ?? "Student"
        )
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

   
    static func message(for error: Error) -> String {
        if let e = error as? AuthFlowError { return e.errorDescription ?? "Something went wrong." }
        let ns = error as NSError
        switch ns.code {
        case 17007: return "That email is already registered. Try logging in."
        case 17008: return "Enter a valid email address."
        case 17026: return "Password is too weak. Use at least 6 characters."
        case 17009, 17004, 17011: return "Incorrect email or password."
        case 17020: return "No internet connection. Try again."
        case 17010: return "Too many attempts. Try again later."
        default: return error.localizedDescription
        }
    }
}
