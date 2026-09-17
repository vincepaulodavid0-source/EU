
import SwiftUI

struct ItemModel: Identifiable {
    let id = UUID()
    let title: String
    let details: String
    let location: String
    var status: String
    let itemImage: Image?
}
