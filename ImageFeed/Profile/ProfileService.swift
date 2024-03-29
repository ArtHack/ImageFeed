import Foundation

struct ProfileResult: Decodable {
    var userName: String?
    var firstName: String?
    var lastName: String?
    var bio: String?
     
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

public struct Profile {
    let userName: String?
    let name: String?
    let loginName: String?
    let bio: String?
}

final class ProfileService {
    
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private (set) var profile: Profile?
}
extension ProfileService {
    public func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = fetchProfileRequest(token) else { return }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let profileResult):
                self.profile = Profile(
                    userName: profileResult.userName ?? "",
                    name: "\(profileResult.firstName ?? "")" + " " + "\(profileResult.lastName ?? "")",
                    loginName: "@\(profileResult.userName ?? "")",
                    bio: profileResult.bio ?? "")
                completion(.success(self.profile!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task?.resume()
    }
    
    private func fetchProfileRequest(_ token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com") else { return nil }
        
        var request = URLRequest.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURL: url)
        request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clean() {
        profile = nil
        task?.cancel()
        task = nil
    }
}
