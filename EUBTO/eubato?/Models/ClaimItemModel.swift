
import SwiftUI

struct ClaimItemModel: Identifiable {
    let id = UUID()
    let itemTitle: String
    let ticketNumber: String
    let status: String
    let dateSubmitted: String
}
