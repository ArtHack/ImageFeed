import Foundation

struct PhotoResult: Decodable {
    
}

struct UrlsResult {
    
}

struct Photo {
    let id : String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

class ImagesListService {
    private (set) var photos: [Photo] = []
    static let DidChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private var lastLoadedPage: Int?
    
    private func fetchPhotosNextPage () {
    }
}
