import SwiftUI
import Combine

class ItemController: ObservableObject {
    @Published var feedItems: [ItemModel] = []
    
    func addNewItem(title: String, details: String, location: String, status: String, image: Image) {
        let newItem = ItemModel(
            title: title.isEmpty ? "Unnamed Item" : title,
            details: details,
            location: location,
            status: status,
            itemImage: image
        )
        feedItems.append(newItem)
    }
}
