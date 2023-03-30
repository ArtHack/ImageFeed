import Foundation

struct UserResult: Decodable {
    let profileImage: ImageURL?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ImageURL: Decodable {
    let smallImage: String?
}

final class ProfileImageService {
    
    static let DidCahngeNottification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
}

extension ProfileImageService {
    
    func fetchProfileImageURL(_ token: String, username: String?, completion: @escaping (Result<String?, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let username = username else { return }
        guard let request = fetchProfileImageRequest(token, username: username) else { return }
                
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in

            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage?.smallImage
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidCahngeNottification,
                        object: self,
                        userInfo: ["URL": self.avatarURL ?? ""])
                completion(.success(self.avatarURL))
                print(self.avatarURL)
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
        self.task = task
        task?.resume()
    }
    
    private func fetchProfileImageRequest(_ token: String, username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com") else { return nil }
        var request = URLRequest.makeHTTPRequest(
            path: "/users/\(username)",
            httpMethod: "GET",
            baseURL: url)
        request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
