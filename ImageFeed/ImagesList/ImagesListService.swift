import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let welcomeDescription: String?
    let isLiked: Bool?
    let urls: UrlsResult?
    let width: Int?
    let height: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case welcomeDescription = "description"
        case isLiked = "liked_by_user"
        case urls = "urls"
        case width = "width"
        case height = "height"
    }
}

struct UrlsResult: Decodable {
    let raw: String?
    let full: String?
    let regular : String?
    let small: String?
    let thumb: String?
    
    enum CodingKeys: String, CodingKey {
        case raw = "raw"
        case full = "full"
        case regular = "regular"
        case small = "small"
        case thumb = "thumb"
    }
}

struct Photo {
    let id : String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool
}

final class ImagesListService {
    private (set) var photos: [Photo] = []
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    private var lastLoadedPage: Int?
    private let perPage = "10"
    private var task: URLSessionTask?
    private let token = OAuth2TokenStorage().token
    static let shared = ImagesListService()
    private let imageListService = ImagesListService()
    
    func fetchPhotosNextPage() {
        let nextPage = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        
        guard let token = token else { return }
        guard let request = fetchImagesListRequest(token, page: String(nextPage), perPage: perPage) else { return }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                [weak self] in
                guard let self = self else { return }
                self.task = nil
                switch result {
                case.success(let photoResult):
                    for photo in photoResult {
                        self.photos.append(self.convert(from: photo))
                    }
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default
                        .post(name: ImagesListService.didChangeNotification,
                              object: self,
                              userInfo: ["Images" : self.photos])
                case.failure(let error):
                    assertionFailure("Ошибка \(error)")
                }
            }
        }
        self.task = task
        task?.resume()
        
    }
}
extension ImagesListService {
    func fetchImagesListRequest (_ token: String, page: String, perPage: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: defaultBaseURL)
        request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func convert (from photoResult: PhotoResult) -> Photo {
        let dateFormat = ISO8601DateFormatter()
        let date = dateFormat.date(from: photoResult.createdAt ?? "")
        return Photo.init(id: photoResult.id,
                          size: CGSize(width: photoResult.width ?? 1, height: photoResult.height ?? 1),
                          createdAt: date,
                          welcomeDescription: photoResult.welcomeDescription,
                          thumbImageURL: photoResult.urls?.thumb,
                          largeImageURL: photoResult.urls?.small,
                          isLiked: photoResult.isLiked ?? false)
    }
}



