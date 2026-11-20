import SwiftUI


struct RemoteImage: View {
    let url: String?

    private static let cache = NSCache<NSString, UIImage>()

    var body: some View {
        if let url, url.hasPrefix("data:"), let ui = Self.decode(url) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else if let url, !url.hasPrefix("data:"), let u = URL(string: url) {
            AsyncImage(url: u) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure: placeholder
                default: ZStack { Color(.systemGray5); ProgressView() }
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "photo.fill").foregroundColor(.secondary)
        }
    }

    private static func decode(_ s: String) -> UIImage? {
        if let cached = cache.object(forKey: s as NSString) { return cached }
        guard let comma = s.firstIndex(of: ","),
              let data = Data(base64Encoded: String(s[s.index(after: comma)...])),
              let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: s as NSString)
        return image
    }
}
